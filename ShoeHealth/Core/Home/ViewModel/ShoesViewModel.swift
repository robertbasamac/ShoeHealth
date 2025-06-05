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
    
    @ObservationIgnored private let shoeHandler: ShoeHandler

    @ObservationIgnored private let defaults = UserDefaults(suiteName: System.AppGroups.shoeHealth)
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    
    private(set) var shoes: [Shoe] = []
    
    /// Searching
    private(set) var searchText: String = ""
    var searchBinding: Binding<String> {
        Binding(
            get: { self.searchText },
            set: { self.searchText = $0 }
        )
    }
    
    /// Sorting
    var sortingRuleBinding: Binding<SortingRule> {
        Binding(
            get: { self.sortingRule },
            set: { self.sortingRule = $0 }
        )
    }
    private(set) var sortingRule: SortingRule {
        didSet {
            defaults?.set(sortingRule.rawValue, forKey: "SORTING_RULE")
        }
    }
    private(set) var sortingOrder: SortingOrder {
        didSet {
            defaults?.set(sortingOrder.rawValue, forKey: "SORTING_ORDER")
        }
    }
    
    init(shoeHandler: ShoeHandler) {
        self.shoeHandler = shoeHandler
        
        let sortingRule = defaults?.string(forKey: "SORTING_RULE") ?? SortingRule.aquisitionDate.rawValue
        self.sortingRule = SortingRule(rawValue: sortingRule) ?? SortingRule.recentlyUsed
        
        let sortingOrder = defaults?.string(forKey: "SORTING_ORDER") ?? SortingOrder.forward.rawValue
        self.sortingOrder = SortingOrder(rawValue: sortingOrder) ?? SortingOrder.forward
        
        fetchShoes()
        setupObservers()
    }
    
    // MARK: - Filtered Content
    var filteredShoes: [Shoe] {
        guard !searchText.isEmpty else { return shoes }
        
        return shoes.filter {
            $0.brand.localizedCaseInsensitiveContains(searchText) ||
            $0.model.localizedCaseInsensitiveContains(searchText) ||
            $0.nickname.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Premium Content
    
    func isShoesLimitReached() -> Bool {
        return shoes.count >= StoreManager.shoesLimit
    }
    
    func shouldRestrictShoe(_ shoeID: UUID) -> Bool {
        if StoreManager.shared.hasFullAccess {
            return false
        }
        
        if !isShoesLimitReached() {
            return false
        }
        
        var allowedShoes: [UUID] = []
        
        if let defautlShoe = getDefaultShoe(for: .daily) {
            allowedShoes.append(defautlShoe.id)
        }
        
        if allowedShoes.count < StoreManager.shoesLimit {
            let neededShoes = StoreManager.shoesLimit - allowedShoes.count
            let recentlyUsedShoes = getRecentlyUsedShoes(exclude: allowedShoes, prefix: neededShoes).map { $0.id }
            allowedShoes.append(contentsOf: recentlyUsedShoes)
        }
        
        if allowedShoes.count < StoreManager.shoesLimit {
            let neededShoes = StoreManager.shoesLimit - allowedShoes.count
            let recentlyAddedShoes = getRecentlyAddedShoes(exclude: allowedShoes, prefix: neededShoes).map { $0.id }
            allowedShoes.append(contentsOf: recentlyAddedShoes)
        }
        
        return !allowedShoes.contains(shoeID)
    }

    
    // MARK: - Getters
    
    func getShoe(forID shoeID: UUID) -> Shoe? {
        return shoes.first { $0.id == shoeID }
    }
    
    func getShoe(ofWorkoutID workoutID: UUID) -> Shoe? {
        return shoes.first { $0.workouts.contains(workoutID) }
    }
    
    func getDefaultShoe(for runType: RunType) -> Shoe? {
        return shoes.first(where: { $0.isDefaultShoe && $0.defaultRunTypes.contains(runType) })
    }
    
    func getAllDefaultShoes() -> [Shoe] {
        return shoes.filter { $0.isDefaultShoe && !$0.defaultRunTypes.isEmpty }
    }
    
    func getRecentlyUsedShoes(exclude excludedShoes: [UUID] = [], prefix: Int = 5) -> [Shoe] {
        guard prefix > 0 else { return [] }

        return shoes
            .filter { shoe in
                !excludedShoes.contains(shoe.id) && shoe.lastActivityDate != nil
            }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.lastActivityDate, let rhsDate = rhs.lastActivityDate else { return false }
                return lhsDate > rhsDate
            }
            .prefix(prefix)
            .map { $0 }
    }
    
    func getRecentlyAddedShoes(exclude excludedShoes: [UUID], prefix: Int = 0) -> [Shoe] {
        guard prefix > 0 else { return [] }

        return shoes
            .filter { !excludedShoes.contains($0.id) }
            .sorted(by: { $0.aquisitionDate > $1.aquisitionDate })
            .prefix(prefix)
            .map { $0 }
    }
    
    func getShoes(for category: ShoeCategory = .all, sortingRule: SortingRule? = nil, sortingOrder: SortingOrder? = nil) -> [Shoe] {
        var filteredShoes: [Shoe] = []
        
        switch category {
        case .active:
            filteredShoes = self.shoes.filter({ !$0.isRetired })
        case .retired:
            filteredShoes = self.shoes.filter({ $0.isRetired })
        case .all:
            filteredShoes = self.shoes
        }
        
        let ruleToApply = sortingRule ?? self.sortingRule
        let orderToApply = sortingOrder ?? self.sortingOrder
        
        switch ruleToApply {
        case .model:
            filteredShoes.sort { orderToApply == .forward ? $0.model < $1.model : $0.model > $1.model }
        case .brand:
            filteredShoes.sort { orderToApply == .forward ? $0.brand < $1.brand : $0.brand > $1.brand }
        case .distance:
            filteredShoes.sort { orderToApply == .forward ? $0.totalDistance < $1.totalDistance : $0.totalDistance > $1.totalDistance }
        case .wear:
            filteredShoes.sort { orderToApply == .forward ? $0.wearPercentage < $1.wearPercentage : $0.wearPercentage > $1.wearPercentage }
        case .recentlyUsed:
            filteredShoes.sort { orderToApply == .forward ? $0.lastActivityDate ?? Date.distantPast > $1.lastActivityDate ?? Date.distantPast : $0.lastActivityDate ?? Date.distantPast < $1.lastActivityDate ?? Date.distantPast }
        case .aquisitionDate:
            filteredShoes.sort { orderToApply == .forward ? $0.aquisitionDate > $1.aquisitionDate : $0.aquisitionDate < $1.aquisitionDate }
        }
        
        return filteredShoes
    }
    
    // MARK: - CRUD operations
    
    func addShoe(
        nickname: String,
        brand: String,
        model: String,
        lifespanDistance: Double,
        aquisitionDate: Date,
        isDefaultShoe: Bool,
        defaultRunTypes: [RunType],
        suitableRunTypes: [RunType],
        image: Data?
    ) -> Shoe {
        let newShoe = Shoe(
            image: image,
            brand: brand,
            model: model,
            nickname: nickname,
            lifespanDistance: lifespanDistance,
            aquisitionDate: aquisitionDate,
            isDefaultShoe: isDefaultShoe,
            defaultRunTypes: defaultRunTypes,
            suitableRunTypes: suitableRunTypes
        )
        
        if isDefaultShoe {
            for otherShoe in shoes {
                otherShoe.defaultRunTypes.removeAll(where: { defaultRunTypes.contains($0) })
                
                if otherShoe.defaultRunTypes.isEmpty {
                    otherShoe.isDefaultShoe = false
                }
            }
        }
        
        shoeHandler.addShoe(newShoe)
        fetchShoes()
        
        return newShoe
    }
    
    func updateShoe(
        shoeID: UUID,
        nickname: String,
        brand: String,
        model: String,
        isDefaultShoe: Bool,
        defaultRunTypes: [RunType],
        suitableRunTypes: [RunType],
        lifespanDistance: Double,
        aquisitionDate: Date,
        image: Data?
    ) {
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
        shoe.isDefaultShoe = isDefaultShoe
        shoe.defaultRunTypes = isDefaultShoe ? defaultRunTypes : []
        shoe.suitableRunTypes = suitableRunTypes
        
        if isDefaultShoe {
            for otherShoe in shoes.filter({ $0.id != shoeID }) {
                otherShoe.defaultRunTypes.removeAll(where: { defaultRunTypes.contains($0) })
                
                if otherShoe.defaultRunTypes.isEmpty {
                    otherShoe.isDefaultShoe = false
                }
            }
        }

        shoeHandler.saveContext()
        fetchShoes()
    }
    
    func deleteShoe(at offsets: IndexSet) {
        withAnimation {
            offsets.map { self.shoes[$0] }.forEach { shoe in
                shoeHandler.deleteShoe(shoe)
            }
        }
        
        fetchShoes()
    }
    
    func deleteShoe(_ shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        shoes.removeAll { $0.id == shoeID }
        shoeHandler.deleteShoe(shoe)
        
        fetchShoes()
    }
    
    // MARK: - Handling Shoes Methods

    @MainActor
    func add(workoutIDs: [UUID], toShoe shoeID: UUID) async {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        var oldShoes: [Shoe] = []
        
        for workoutID in workoutIDs {
            if let oldShoe = getShoe(ofWorkoutID: workoutID) {
                oldShoe.workouts.removeAll { $0 == workoutID }
                oldShoes.append(oldShoe)
            }
        }
        
        oldShoes = Array(Set(oldShoes))
        
        for oldShoe in oldShoes {
            await updateShoeStatistics(oldShoe)
        }
        
        let previousWear = shoe.wearCondition
        shoe.workouts.append(contentsOf: workoutIDs)
        
        await updateShoeStatistics(shoe)
        
        shoeHandler.saveContext()
        fetchShoes()
        
        // TO DO - move this outside of ShoesViewModel if possible
        HealthManager.shared.updateLatestUpdateDate(from: Array(workoutIDs))

        if !shoe.isRetired && shoe.wearCondition.rawValue > previousWear.rawValue && shoe.wearCondition != .new && shoe.wearCondition != .good {
            let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? .now)
            
            NotificationManager.shared.scheduleShoeWearNotification(forShoe: shoe, at: dateComponents)
        }
    }
    
    @MainActor
    func remove(workoutIDs: [UUID], fromShoe shoeID: UUID) async {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        for workoutID in workoutIDs {
            shoe.workouts.removeAll { $0 == workoutID }
        }
        
        await updateShoeStatistics(shoe)
        
        shoeHandler.saveContext()
        fetchShoes()
    }
    
    func setAsDefaultShoe(_ shoeID: UUID, for runTypes: [RunType], append: Bool = false) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        for otherShoe in shoes {
            otherShoe.defaultRunTypes.removeAll(where: { runTypes.contains($0) })
            
            if otherShoe.defaultRunTypes.isEmpty {
                otherShoe.isDefaultShoe = false
            }
        }
        
        if append {
            shoe.defaultRunTypes.append(contentsOf: runTypes)
        } else {
            shoe.defaultRunTypes = runTypes
        }
        
        shoe.suitableRunTypes = Array(Set(shoe.suitableRunTypes).union(runTypes))
        shoe.isDefaultShoe = true
        shoe.isRetired = false
        
        shoeHandler.saveContext()
        fetchShoes()
    }
    
    func setSuitableRunTypes(_ runTypes: [RunType], for shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }

        shoe.suitableRunTypes = runTypes

        shoeHandler.saveContext()
        fetchShoes()
    }
    
    func retireShoe(_ shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        shoe.isRetired.toggle()
        shoe.retireDate = shoe.isRetired ? .now : nil
        
        if shoe.isDefaultShoe && !shoe.defaultRunTypes.isEmpty && shoe.isRetired {
            shoe.isDefaultShoe = false
            shoe.defaultRunTypes = []
        }
        
        shoeHandler.saveContext()
        fetchShoes()
    }
    
    func estimatedRetirementDate(for shoe: Shoe) -> Date? {
        guard shoe.totalDistance < shoe.lifespanDistance else { return nil }
        
        let workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
        logger.debug("Retrieved \(workouts.count) workouts for shoe \(shoe.model)")
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workouts) {
            calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0.startDate)
        }
        
        let sortedGrouped = grouped.sorted {
            guard let date1 = calendar.date(from: $0.key),
                  let date2 = calendar.date(from: $1.key) else { return false }
            return date1 < date2
        }
        
        for (week, workouts) in sortedGrouped {
            logger.debug("Week: \(week)")
            for workout in workouts {
                let distance = workout.totalDistance(unit: SettingsManager.shared.unitOfMeasure.unit)
                let endDate = workout.endDate
                logger.debug("Workout - Distance: \(distance), End Date: \(String(describing: endDate))")
            }
        }
        
        logger.debug("Grouped workouts into \(grouped.keys.count) week groups")
        
        let weeklyTotals = grouped.values.map { group in
            group.reduce(0.0) { $0 + $1.totalDistance(unit: SettingsManager.shared.unitOfMeasure.unit) }
        }
        logger.debug("Computed weekly totals: \(weeklyTotals)")
        
        guard !weeklyTotals.isEmpty else { return nil }
        let averageWeekly = weeklyTotals.reduce(0.0, +) / Double(weeklyTotals.count)
        
        guard averageWeekly > 0 else { return nil }
        
        let remainingDistance = shoe.lifespanDistance - shoe.totalDistance
        let weeksLeft = remainingDistance / averageWeekly
        
        let estimatedDate = calendar.date(byAdding: .day, value: Int(weeksLeft * 7), to: Date())
        logger.debug("Estimated retirement in \(weeksLeft) weeks: \(String(describing: estimatedDate))")
        return estimatedDate
    }
    
    @MainActor
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
            logger.debug("Computing PR for category \(category.rawValue)")

            guard let workoutsForCategory = filteredWorkouts[category] else { continue }
                        
            totalRuns[category] = workoutsForCategory.count
            
            for workout in workoutsForCategory {
                
                group.enter()
                
                HealthManager.shared.fetchDistanceSamples(for: workout) { samples in
                    var accumulatedDistance: Double = 0
                    var lastSampleEndDate: Date?
                    var lastValidSampleEndDate: Date?
                    
                    var currentIndex = 0
                    
                    for sample in samples {
                        let sampleDistance = sample.quantity.doubleValue(for: .meter())

                        currentIndex += 1

                        if lastValidSampleEndDate == nil || ((self.compareDatesIgnoringMoreGranularComponents(sample.startDate, lastValidSampleEndDate))) {
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
    
    // MARK: - CloudKit Updates Handling
    
    private func setupObservers() {
        SettingsManager.shared.addObserver { [weak self] in
            Task {
                await self?.convertShoesToSelectedUnit()
            }
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
            } else if event.type == .export { }
        }
    }
    
    // MARK: - Other Methods
    
    private func convertShoesToSelectedUnit() async {
        let unitOfMeasure = SettingsManager.shared.unitOfMeasure
        
        let group = DispatchGroup()
        
        for shoe in shoes {
            group.enter()
            
            shoe.lifespanDistance = UnitOfMeasure.convert(distance: shoe.lifespanDistance, toUnit: unitOfMeasure)
            
            await updateShoeStatistics(shoe)
        }
        
        shoeHandler.saveContext()
        fetchShoes()
    }
    
    private func compareDatesIgnoringMoreGranularComponents(_ date1: Date?, _ date2: Date?) -> Bool {
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
    
    func toggleSortOrder() {
        sortingOrder = sortingOrder == .forward ? .reverse : .forward
    }
    
    // MARK: - SwiftData Model Context methods
    
    func fetchShoes() {
        logger.debug("Fetching shoes...")
        
        let descriptor = FetchDescriptor<Shoe>(
            sortBy: [
                SortDescriptor(\.brand, order: .forward),
                SortDescriptor(\.model, order: .forward)
            ]
        )
        
        self.shoes = shoeHandler.fetchShoes(with: descriptor)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
