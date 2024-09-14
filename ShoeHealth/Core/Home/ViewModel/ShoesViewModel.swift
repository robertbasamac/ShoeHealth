//
//  ShoesViewModel.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 12.12.2023.
//

import Foundation
import Observation
import SwiftData
import CoreData
import SwiftUI
import HealthKit
import WidgetKit
import Combine
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "ShoesViewModel")

@Observable
final class ShoesViewModel {
    
    @ObservationIgnored private var modelContext: ModelContext
    
    private(set) var shoes: [Shoe] = []
    
    private(set) var searchText: String = ""
    private(set) var filterType: ShoeCategory = .active
    private(set) var sortType: ShoeSortType = .brand
    private(set) var sortOrder: SortOrder = .forward
    
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        fetchShoes()
        setupObservers()
    }
    
    // MARK: - CRUD operations
    
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
            shoe.isRetired = false
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
    
    // MARK: - Handling Shoes Methods

    func add(workoutIDs: [UUID], toShoe shoeID: UUID) async {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        for workoutID in workoutIDs {
            if let oldShoe = getShoe(ofWorkoutID: workoutID) {
                oldShoe.workouts.removeAll { $0 == workoutID }
                
                await updateShoeStatistics(oldShoe)
            }
        }
        
        let previousWear = shoe.wearCondition
        
        shoe.workouts.append(contentsOf: workoutIDs)
        
        await updateShoeStatistics(shoe)
        
        save()
        
        HealthManager.shared.updateLatestUpdateDate(from: Array(workoutIDs))

        if !shoe.isRetired && shoe.wearCondition.rawValue > previousWear.rawValue && shoe.wearCondition != .new && shoe.wearCondition != .good {
            let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
            let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date ?? .now)
            
            NotificationManager.shared.scheduleShoeWearNotification(forShoe: shoe, at: dateComponents)
        }
    }
    
    func remove(workoutIDs: [UUID], fromShoe shoeID: UUID) async {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        for workoutID in workoutIDs {
            shoe.workouts.removeAll { $0 == workoutID }
        }
        
        await updateShoeStatistics(shoe)
        
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
        
        // no retired shoe can be default shoe
        if shoe.isRetired && shoe.isDefaultShoe {
            shoe.isDefaultShoe = false
        }
        
        save()
    }
    
    private func computePersonalBests(for shoe: Shoe) async {
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
            
            logger.debug("Computing PR for category \(category.rawValue)")
            
            totalRuns[category] = workoutsForCategory.count
            
            for workout in workoutsForCategory {
                logger.debug("Computing \(workout.totalDistance(unit: SettingsManager.shared.unitOfMeasure.unit))")

                group.enter()
                
                HealthManager.shared.fetchDistanceSamples(for: workout) { samples in
                    var accumulatedDistance: Double = 0
                    var lastSampleEndDate: Date?
                    var lastValidSampleEndDate: Date?
                    
                    var currentIndex = 0
                    
                    for sample in samples {
                        let sampleDistance = sample.quantity.doubleValue(for: .meter())

                        currentIndex += 1

                        if lastValidSampleEndDate == nil || self.compareDatesIgnoringMoreGranularComponents(sample.startDate, lastValidSampleEndDate) {
                            if accumulatedDistance + sampleDistance >= category.distance {
                                logger.debug("Accumulated distance greater than the category distance, (+ \(sampleDistance)): \(accumulatedDistance + sampleDistance)")
                                
                                let sampleDuration = sample.endDate.timeIntervalSince(sample.startDate)
                                
                                let remainingDistance = category.distance - accumulatedDistance
                                let proportion = remainingDistance / sampleDistance
                                let interpolatedTime = proportion * sampleDuration
                                
                                lastSampleEndDate = Date(timeInterval: interpolatedTime, since: sample.startDate)
                                break
                            }
                            
                            accumulatedDistance += sampleDistance
                            lastValidSampleEndDate = sample.endDate
                            logger.debug("\(currentIndex) - Accumulated distance (+ \(sampleDistance), \(sample.endDate)) = \(accumulatedDistance)")
                        } else {
                            logger.warning("Sample not satysfying the date condition, skipping: \(sampleDistance), \(sample.startDate)")
                        }
                    }
                    
                    logger.debug("Total samples counted for category \(category.rawValue), \(currentIndex), from total of \(samples.count)")
                    
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
        
        await withCheckedContinuation { continuation in
            group.notify(queue: .main) {
                shoe.personalBests = personalBests
                shoe.totalRuns = totalRuns
                continuation.resume()
            }
        }
        
        logger.debug("Personal bests computed for \(shoe.model).")
    }
    
    func compareDatesIgnoringMoreGranularComponents(_ date1: Date?, _ date2: Date?) -> Bool {
        // If both dates are nil, consider them equal
        if date1 == nil && date2 == nil {
            return true
        }

        // If only one date is nil, they are not equal
        guard let date1 = date1, let date2 = date2 else {
            return false
        }

        // Compare the specific components (year, month, day, hour, minute, second)
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date2)

        if let year1 = components1.year, let year2 = components2.year, year1 != year2 {
            return year1 > year2
        }
        
        if let month1 = components1.month, let month2 = components2.month, month1 != month2 {
            return month1 > month2
        }
        
        if let day1 = components1.day, let day2 = components2.day, day1 != day2 {
            return day1 > day2
        }
        
        if let hour1 = components1.hour, let hour2 = components2.hour, hour1 != hour2 {
            return hour1 > hour2
        }
        
        if let minute1 = components1.minute, let minute2 = components2.minute, minute1 != minute2 {
            return minute1 > minute2
        }
        
        if let second1 = components1.second, let second2 = components2.second, second1 != second2 {
            return second1 > second2
        }
        
        return true
    }
    
    private func updateShoeStatistics(_ shoe: Shoe) async {
        let unitOfMeasure = SettingsManager.shared.unitOfMeasure
        
        let workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
        
        shoe.lastActivityDate = workouts.first?.endDate
        
        shoe.totalDistance = workouts.reduce(0.0) { result, workout in
            return result + workout.totalDistance(unit: unitOfMeasure.unit)
        }
        
        shoe.totalDuration = workouts.reduce(0.0) { result, workout in
            return result + workout.duration
        }
        
        await computePersonalBests(for: shoe)
    }
    
    // MARK: - Getters
    
    func getShoe(forID shoeID: UUID) -> Shoe? {
        guard let shoe = self.shoes.first(where: { $0.id == shoeID } ) else { return nil }
        return shoe
    }
    
    func getShoe(ofWorkoutID workoutID: UUID) -> Shoe? {
        return shoes.first { shoe in
            shoe.workouts.contains(workoutID)
        }
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
    
    func getShoes(filter: ShoeCategory = .all) -> [Shoe] {
        var filteredShoes: [Shoe] = []
        
        switch filter {
        case .active:
            filteredShoes = self.shoes.filter({ !$0.isRetired })
        case .retired:
            filteredShoes = self.shoes.filter({ $0.isRetired })
        case .all:
            filteredShoes = self.shoes
        }
        
        return filteredShoes.sorted { $0.lastActivityDate ?? Date() > $1.lastActivityDate ?? Date() }
    }
    
    // MARK: - Other Methods
    
    private func setupObservers() {
        SettingsManager.shared.addObserver { [weak self] in
            self?.convertShoesToSelectedUnit()
        }
        
        NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .sink { [weak self] notification in
                self?.handleCloudKitEvent(notification: notification)
            }
            .store(in: &cancellables)
    }
    
    
    private func handleCloudKitEvent(notification: Notification) {
        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
            return
        }
        
        if event.endDate != nil {
            if event.type == .import {
                fetchShoes()
            } else if event.type == .export {
            }
        }
    }
    
    func fetchShoes() {
        logger.debug("Fetching shoes...")

        do {
            let descriptor = FetchDescriptor<Shoe>(sortBy: [SortDescriptor(\.brand, order: .forward), SortDescriptor(\.model, order: .forward)])
            
            let shoes = try modelContext.fetch(descriptor)
            
            Task { @MainActor in
                self.shoes = shoes
            }
        } catch {
            logger.error("Fetching shoes failed, \(error.localizedDescription)")
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func convertShoesToSelectedUnit() {
        let unitOfMeasure = SettingsManager.shared.unitOfMeasure
        
        for shoe in shoes {
            switch unitOfMeasure {
            case .imperial:
                shoe.lifespanDistance = shoe.lifespanDistance / 1.60934
            case .metric:
                shoe.lifespanDistance = shoe.lifespanDistance * 1.60934
            }

            Task {
                await updateShoeStatistics(shoe)
            }
        }
        
        save()
    }
    
    func toggleSortOrder() {
        sortOrder = sortOrder == .forward ? .reverse : .forward
    }
    
    // MARK: - SwiftData Model Context methods
    
    private func save() {
        do {
            try modelContext.save()
            
            logger.debug("Context saved successfully.")
        } catch {
            logger.error("Saving context failed, \(error.localizedDescription)")
        }
        
        fetchShoes()
    }
}
