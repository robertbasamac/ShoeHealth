//
//  ShoesViewModel.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 12.12.2023.
//

import Foundation
import Observation
import SwiftData
import SwiftUI
import HealthKit
import WidgetKit

@Observable
final class ShoesViewModel: @unchecked Sendable {
    
    @ObservationIgnored private var modelContext: ModelContext
    
    private(set) var shoes: [Shoe] = []
    
    private(set) var searchText: String = ""
    private(set) var filterType: ShoeFilterType = .active
    private(set) var sortType: ShoeSortType = .brand
    private(set) var sortOrder: SortOrder = .forward
    
    var searchBinding: Binding<String> {
        Binding(
            get: { self.searchText },
            set: { self.searchText = $0 }
        )
    }
    var filterTypeBinding: Binding<ShoeFilterType> {
        Binding(
            get: { self.filterType },
            set: { self.filterType = $0 }
        )
    }
    var sortTypeBinding: Binding<ShoeSortType> {
        Binding(
            get: { self.sortType },
            set: { self.sortType = $0 }
        )
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchShoes()
    }
    
    // MARK: - Computed Properties
    
    var filteredShoes: [Shoe] {
        var filteredShoes: [Shoe] = []
        
        switch filterType {
        case .active:
            filteredShoes = shoes.filter { !$0.isRetired }
        case .retired:
            filteredShoes = shoes.filter { $0.isRetired }
        case .all:
            filteredShoes = shoes
        }
        
        switch sortType {
        case .model:
            filteredShoes.sort { sortOrder == .forward ? $0.model < $1.model : $0.model > $1.model }
        case .brand:
            filteredShoes.sort { sortOrder == .forward ? $0.brand < $1.brand : $0.brand > $1.brand }
        case .distance:
            filteredShoes.sort { sortOrder == .forward ? $0.totalDistance < $1.totalDistance : $0.totalDistance > $1.totalDistance }
        case .wear:
            filteredShoes.sort { sortOrder == .forward ? $0.wearPercentage < $1.wearPercentage : $0.wearPercentage > $1.wearPercentage }
        case .lastRunDate:
            filteredShoes.sort { sortOrder == .forward ? $0.lastActivityDate ?? Date() < $1.lastActivityDate ?? Date() : $0.lastActivityDate ?? Date() > $1.lastActivityDate ?? Date() }
        }
        
        return filteredShoes
    }
    
    var searchFilteredShoes: [Shoe] {
        guard !searchText.isEmpty else {
            return filteredShoes
        }
        
        var filteredShoes: [Shoe] = []
        
        switch filterType {
        case .active:
            filteredShoes = shoes.filter { !$0.isRetired }
        case .retired:
            filteredShoes = shoes.filter { $0.isRetired }
        case .all:
            filteredShoes = shoes
        }
        
        filteredShoes = filteredShoes.filter { $0.brand.localizedCaseInsensitiveContains(searchText) || $0.model.localizedCaseInsensitiveContains(searchText) }
        filteredShoes.sort { $0.model < $1.model }
        
        return filteredShoes
    }
    
    // MARK: - Handling Shoes Methods
    
    func addShoe(nickname: String, brand: String, model: String, lifespanDistance: Double, aquisitionDate: Date, isDefaultShoe: Bool, image: Data?) {
        let shoe = Shoe(nickname: nickname, brand: brand, model: model, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, isDefaultShoe: isDefaultShoe, image: image)
        
        if isDefaultShoe, let previousDefaultShoe = shoes.first(where: { $0.isDefaultShoe} ) {
            previousDefaultShoe.isDefaultShoe = false
        }
        
        if shoes.isEmpty {
            shoe.isDefaultShoe = true
        }
        
        modelContext.insert(shoe)
        
        save()
    }
    
    func updateShoe(shoeID: UUID, nickname: String, brand: String, model: String, setDefaultShoe: Bool, lifespanDistance: Double, aquisitionDate: Date, image: Data?) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        if !brand.isEmpty {
            shoe.brand = brand
        }
        if !model.isEmpty {
            shoe.model = model
        }
        if !nickname.isEmpty {
            shoe.nickname = nickname
        }
        
        if setDefaultShoe {
            if let defaultShoe = getDefaultShoe() {
                defaultShoe.isDefaultShoe = false
            }
            
            shoe.isDefaultShoe = setDefaultShoe
        }
        
        shoe.image = image
        shoe.aquisitionDate = aquisitionDate
        shoe.lifespanDistance = lifespanDistance
        
        save()
    }
    
    func deleteShoe(at offsets: IndexSet) {
        withAnimation {
            offsets.map { self.shoes[$0] }.forEach { shoe in
                modelContext.delete(shoe)
            }
        }
        
        save()
    }
    
    func deleteShoe(_ shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        self.shoes.removeAll { $0.id == shoeID }
        modelContext.delete(shoe)
        
        save()
    }
    
    func add(workoutIDs: Set<UUID>, toShoe shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        for workoutID in workoutIDs {
            if let oldShoe = getShoe(ofWorkoutID: workoutID) {
                oldShoe.workouts.removeAll { $0 == workoutID }
                updateShoeStatistics(oldShoe)
            }
        }
        
        shoe.workouts.append(contentsOf: workoutIDs)
        updateShoeStatistics(shoe)
        
        save()
    }
    
    func remove(workoutIDs: Set<UUID>, fromShoe shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        for workoutID in workoutIDs {
            shoe.workouts.removeAll { $0 == workoutID }
        }
        
        updateShoeStatistics(shoe)
        save()
    }
    
    func setAsDefaultShoe(_ shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        if let defaultShoe = getDefaultShoe() {
            defaultShoe.isDefaultShoe = false
        }
        
        shoe.isDefaultShoe = true
        shoe.isRetired = false
        
        save()
    }
    
    func retireShoe(_ shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        shoe.isRetired.toggle()
        shoe.retireDate = shoe.isRetired ? .now : nil
        
        save()
    }
    
    func computePersonalBests(for shoe: Shoe) {
        var personalBests: [RunningCategory: PersonalBest?] = [:]
        var totalRuns: [RunningCategory: Int] = [:]
        
        var filteredWorkouts: [RunningCategory: [HKWorkout]] = [:]
        
        let workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
        
        for category in RunningCategory.allCases {
            personalBests[category] = nil
            totalRuns[category] = 0
            filteredWorkouts[category] = workouts.filter { $0.totalDistance?.doubleValue(for: .meter()) ?? 0 >= category.distance }
        }
        
        let group = DispatchGroup()
        
        for category in RunningCategory.allCases {
            guard let workoutsForCategory = filteredWorkouts[category] else { continue }
            
            totalRuns[category] = workoutsForCategory.count
            
            for workout in workoutsForCategory {
                group.enter()
                
                HealthManager.shared.fetchDistanceSamples(for: workout) { samples in
                    var accumulatedDistance: Double = 0
                    var lastSampleEndDate: Date?
                    
                    for sample in samples {
                        let sampleDistance = sample.quantity.doubleValue(for: .meter())

                        if accumulatedDistance + sampleDistance >= category.distance {
                            let sampleDuration = sample.endDate.timeIntervalSince(sample.startDate)

                            let remainingDistance = category.distance - accumulatedDistance
                            let proportion = remainingDistance / sampleDistance
                            let interpolatedTime = proportion * sampleDuration
                            
                            lastSampleEndDate = Date(timeInterval: interpolatedTime, since: sample.startDate)
                            
                            break
                        }
                        
                        accumulatedDistance += sampleDistance
                    }
                    
                    if let lastSampleEndDate = lastSampleEndDate {
                        let timeInterval = lastSampleEndDate.timeIntervalSince(workout.startDate)
                        
                        if personalBests[category] == nil || timeInterval < personalBests[category]!!.time {
                            personalBests[category] = PersonalBest(time: timeInterval, workoutID: workout.id)
                        }
                    }
                    
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            shoe.personalBests = personalBests
            shoe.totalRuns = totalRuns
        }
    }
    
    private func updateShoeStatistics(_ shoe: Shoe) {
        let workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
        
        shoe.lastActivityDate = workouts.first?.endDate
        
        shoe.totalDistance = workouts.reduce(0.0) { result, workout in
            return result + workout.totalDistance(unitPrefix: .kilo)
        }
        
        shoe.totalDuration = workouts.reduce(0.0) { result, workout in
            return result + workout.duration
        }
        
        computePersonalBests(for: shoe)
    }
    
    // MARK: - Getters
    
    func getShoe(forID shoeID: UUID) -> Shoe? {
        guard let shoe = self.shoes.first(where: { $0.id == shoeID } ) else { return nil }
        return shoe
    }
    
    func getDefaultShoe() -> Shoe? {
        guard let shoe = self.shoes.first(where: { $0.isDefaultShoe } ) else { return nil }
        return shoe
    }
    
    func getRecentlyUsedShoes() -> [Shoe] {
        var recentlyUsedShoes: [Shoe] = self.shoes.filter { $0.lastActivityDate != nil  }
        
        recentlyUsedShoes.sort { $0.lastActivityDate ?? Date() > $1.lastActivityDate ?? Date() }
        
        return Array(recentlyUsedShoes.prefix(5))
    }
    
    func getShoes(filter: ShoeFilterType = .all) -> [Shoe] {
        switch filter {
        case .active:
            return self.shoes.filter({ !$0.isRetired })
        case .retired:
            return self.shoes.filter({ $0.isRetired })
        case .all:
            return self.shoes
        }
    }
    
    // MARK: - Other Methods
    
    private func fetchShoes() {
        do {
            let descriptor = FetchDescriptor<Shoe>(sortBy: [SortDescriptor(\.brand, order: .forward), SortDescriptor(\.model, order: .forward)])
            self.shoes = try modelContext.fetch(descriptor)
        } catch {
            print("Fetching shoes failed, \(error.localizedDescription)")
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getShoe(ofWorkoutID workoutID: UUID) -> Shoe? {
        return shoes.first { shoe in
            shoe.workouts.contains(workoutID)
        }
    }
    
    func toggleSortOrder() {
        sortOrder = sortOrder == .forward ? .reverse : .forward
    }
    
    // MARK: - SwiftData Model Context methods
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Saving context failed, \(error.localizedDescription)")
        }
        
        fetchShoes()
    }
}
