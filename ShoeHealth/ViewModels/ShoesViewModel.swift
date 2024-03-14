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
final class ShoesViewModel {
    
    private var modelContext: ModelContext
    
    var shoes: [Shoe] = []
    
    var searchText: String = ""
    var filterType: ShoeFilterType = .active
    var sortType: ShoeSortType = .brand
    var sortOrder: SortOrder = .forward
    
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
        
        /// Filter Shoes
        switch filterType {
        case .active:
            filteredShoes = shoes.filter { !$0.retired }
        case .retired:
            filteredShoes = shoes.filter { $0.retired }
        case .all:
            filteredShoes = shoes
        }
        
        /// Sort Shoes
        switch sortType {
        case .model:
            filteredShoes.sort { sortOrder == .forward ? $0.model > $1.model : $0.model < $1.model }
        case .brand:
            filteredShoes.sort { sortOrder == .forward ? $0.brand > $1.brand : $0.brand < $1.brand }
        case .distance:
            filteredShoes.sort { sortOrder == .forward ? $0.currentDistance > $1.currentDistance : $0.currentDistance < $1.currentDistance }
        case .aquisitionDate:
            filteredShoes.sort { sortOrder == .forward ? $0.aquisitionDate > $1.aquisitionDate : $0.aquisitionDate < $1.aquisitionDate }
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
            filteredShoes = shoes.filter { !$0.retired }
        case .retired:
            filteredShoes = shoes.filter { $0.retired }
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
    
    func updateShoe(shoeID: UUID, nickname: String, brand: String, model: String, lifespanDistance: Double, aquisitionDate: Date, image: Data?) {
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
        
        modelContext.delete(shoe)
        save()
    }
    
    func add(workouts: Set<UUID>, toShoe shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        let workoutsData = HealthKitManager.shared.getWorkouts(forIDs: Array(workouts))
        
        for workout in workoutsData {
            shoe.currentDistance += workout.totalDistance(unitPrefix: .kilo)
        }
        shoe.workouts.append(contentsOf: workouts)
        
        save()
    }
    
    func remove(workout: UUID, fromShoe shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        if let workoutData = HealthKitManager.shared.getWorkout(forID: workout) {
            shoe.currentDistance -= workoutData.totalDistance(unitPrefix: .kilo)
            shoe.currentDistance = shoe.currentDistance < 0 ? 0 : shoe.currentDistance
        }
        shoe.workouts.removeAll { $0 == workout }
        
        save()
    }
    
    func setAsDefaultShoe(_ shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        if let defaultShoe = getDefaultShoe() {
            defaultShoe.isDefaultShoe = false
        }
        
        shoe.isDefaultShoe = true
        
        save()
    }
    
    func retireShoe(_ shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        shoe.retired.toggle()
        
        save()
    }
    
    // MARK: - Getters
    
    func getDefaultShoe() -> Shoe? {
        guard let shoe = self.shoes.first(where: { $0.isDefaultShoe } ) else { return nil }
        return shoe
    }
    
    func getShoe(forID shoeID: UUID) -> Shoe? {
        guard let shoe = self.shoes.first(where: { $0.id == shoeID } ) else { return nil }
        return shoe
    }
    
    // MARK: - Other Methods
    
    func fetchShoes() {
        do {
            let descriptor = FetchDescriptor<Shoe>(sortBy: [SortDescriptor(\.brand, order: .forward), SortDescriptor(\.model, order: .forward)])
            self.shoes = try modelContext.fetch(descriptor)
        } catch {
            print("Fetching shoes failed, \(error.localizedDescription)")
        }
        
        WidgetCenter.shared.reloadAllTimelines()
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
