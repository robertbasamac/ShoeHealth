//
//  HealthManager.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import Foundation
import HealthKit
import Observation
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "HealthManager")

struct RunningWorkout {
    
    var workout: HKWorkout
    private var averageHeartRate: Double = 0.0
    private var averageCadence: Double = 0.0
    private var averagePower: Double = 0.0
    
    init(workout: HKWorkout) {
        self.workout = workout
    }
    
    var wrappedAveragePace: (Int, Int) {
        return self.workout.averagePace(unit: SettingsManager.shared.unitOfMeasure.unit)
    }
    
    var wrappedAverageHeartRate: Double {
        return self.workout.averageHeartRate == 0 ? self.averageHeartRate : self.workout.averageHeartRate
    }
    
    var wrappedAverageCadence: Double {
        return self.workout.averageCadence == 0 ? self.averageCadence : self.workout.averageCadence
    }
    
    var wrappedAveragePower: Double {
        return self.workout.averagePower == 0 ? self.averagePower : self.workout.averagePower
    }
    
    mutating func setAverageHeartRate(_ value: Double) {
        self.averageHeartRate = value
    }
    
    mutating func setAverageCadence(_ value: Double) {
        self.averageCadence = value
    }
    
    mutating func setAveragePower(_ value: Double) {
        self.averagePower = value
    }
}

@Observable
final class HealthManager {
    
    static let shared = HealthManager()
    
    @ObservationIgnored private var healthStore = HKHealthStore()
    
    @ObservationIgnored private let readTypes: Set = [HKObjectType.workoutType(),
                                                      HKQuantityType(.distanceWalkingRunning),
                                                      HKQuantityType(.heartRate),
                                                      HKQuantityType(.stepCount),
                                                      HKQuantityType(.runningPower)]
    
    @ObservationIgnored private let sampleType =  HKObjectType.workoutType()
    @ObservationIgnored private let predicate = HKQuery.predicateForWorkouts(with: .running)
    
    private(set) var workouts: [HKWorkout] = [] {
        didSet {
            if let workout = workouts.first {
                guard workout != lastWorkout?.workout else {
                    HealthManager.shared.isLoading = false
                    return
                }
                
                lastWorkout = RunningWorkout(workout: workout)
                
                Task {
                    await calculateLastRunStats()
                    HealthManager.shared.isLoading = false
                }
            } else {
                lastWorkout = nil
                HealthManager.shared.isLoading = false
            }
        }
    }
    
    private(set) var lastWorkout: RunningWorkout? = nil
    
    private(set) var isLoading: Bool = true
    
    @ObservationIgnored var isFetchingWorkouts: Bool = false
    @ObservationIgnored @UserDefault("latestUpdate", defaultValue: Date.distantPast) var latestUpdate: Date
    
    private init() { }
    
    // MARK: - Request HealthKit authorization
    
    func requestHealthAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return false
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            
            await enableBackgroundDelivery()
            
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Observing new Workouts
    
    func startObserving() {
        logger.debug("Start observing new workouts.")

        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return
        }
                
        let query = HKObserverQuery(sampleType: sampleType, predicate: predicate) { (query, completionHandler, error) in
            if let error = error {
                logger.warning("HKObserverQuery returned error, \(error).")
                return
            }
            
            self.handleNewWorkouts()
            
            completionHandler()
        }
        
        self.healthStore.execute(query)
    }
    
    private func enableBackgroundDelivery() async {
        if !HKHealthStore.isHealthDataAvailable() {
            logger.warning("HealthKit is not available on this device.")
            return
        }
        
        do {
            try await healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate)
            
            logger.debug("Background delivery enabled.")
            
            startObserving()
        } catch {
            logger.warning("Could not enable background delivery, \(error.localizedDescription).")
        }
    }
    
    private func handleNewWorkouts() {
        var anchor: HKQueryAnchor?

        let anchoredQuery = HKAnchoredObjectQuery(type: sampleType,
                                                  predicate: predicate,
                                                  anchor: anchor,
                                                  limit: HKObjectQueryNoLimit) { [unowned self] query, newSamples, deletedSamples, newAnchor, error in
            self.updateWorkouts(newSamples: newSamples ?? [], deletedObjects: deletedSamples ?? [])
            anchor = newAnchor
        }
        
        healthStore.execute(anchoredQuery)
    }
    
    private func updateWorkouts(newSamples: [HKSample], deletedObjects: [HKDeletedObject]) {
        let newWorkouts = newSamples.compactMap { $0 as? HKWorkout }
            .filter { $0.endDate > self.latestUpdate }
        
        guard !newWorkouts.isEmpty else {
            logger.warning("Did not manage to convert HKSample to HKWorkout or no new workouts found.")
            return
        }
        
        logger.debug("\(newWorkouts.count) new workout(s) found.")
        
        let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? .now)

        NotificationManager.shared.scheduleNewWorkoutNotification(forNewWorkouts: newWorkouts, at: dateComponents)
        
        if let endDate = newWorkouts.last?.endDate {
            self.latestUpdate = endDate
            logger.debug("latestUpdate date updated to \(self.latestUpdate)")
        }
        
        Task {
            await self.fetchRunningWorkouts()
        }
    }
    
    // MARK: - Fetching HealthKit Data
        
    func fetchRunningWorkouts() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            HealthManager.shared.isLoading = false
            return
        }
        
        guard !isFetchingWorkouts else {
            logger.debug("Fetching running workouts in progress already.")
            return
        }
        
        isFetchingWorkouts = true
        defer { isFetchingWorkouts = false }

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            let query = HKSampleQuery(sampleType: sampleType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [.init(keyPath: \HKSample.endDate, ascending: false)],
                                      resultsHandler: { query, samples, error in
                if let unwrappedError = error {
                    continuation.resume(throwing: unwrappedError)
                    HealthManager.shared.isLoading = false
                    return
                }
                
                guard let samples = samples else {
                    logger.error("HealthKit not accessable.")
                    HealthManager.shared.isLoading = false
                    return
                }
                
                continuation.resume(returning: samples)
            })
            
            healthStore.execute(query)
        }
        
        guard let workouts = samples as? [HKWorkout] else {
            logger.warning("Did not manage to convert HKSample to HKWorkout.")
            return
        }
        
        logger.debug("\(workouts.count) workouts fetched.")
        
        await MainActor.run {
            self.workouts = workouts
        }
    }
    
    func fetchDistanceSamples(for workout: HKWorkout, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return
        }
        
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate)
        
        var distanceSamples: [HKQuantitySample] = []
        
        let seriesQuery = HKQuantitySeriesSampleQuery(quantityType: distanceType, predicate: predicate) { (query, quantity, dateInterval, series, done, error) in
            if let error = error {
                logger.error("Error fetching distance samples: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let quantity = quantity {
                distanceSamples.append(HKQuantitySample(type: .init(.distanceWalkingRunning), quantity: quantity, start: dateInterval?.start ?? Date(), end: dateInterval?.end ?? Date()))
            }
            
            if done {
                completion(distanceSamples.sorted(by: { $0.endDate < $1.endDate }))
            }
        }
        
        healthStore.execute(seriesQuery)
    }
    
    private func fetchHeartRateSamples(predicate: NSPredicate) async -> [HKQuantitySample] {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return []
        }
        
        return await withCheckedContinuation { continuation in
            let heartRateType = HKQuantityType(.heartRate)
            let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
                guard error == nil, let heartRateSamples = samples as? [HKQuantitySample] else {
                    logger.error("Error fetching heart rate samples: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: heartRateSamples)
            }
            
            healthStore.execute(heartRateQuery)
        }
    }
    
    private func fetchStepCountSamples(predicate: NSPredicate) async -> [HKQuantitySample] {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return []
        }
        
        return await withCheckedContinuation { continuation in
            let stepCountType = HKQuantityType(.stepCount)
            let stepCountQuery = HKSampleQuery(sampleType: stepCountType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
                guard error == nil, let stepSamples = samples as? [HKQuantitySample] else {
                    logger.error("Error fetching step count samples: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: stepSamples)
            }
            
            healthStore.execute(stepCountQuery)
        }
    }
    
    private func fetchPowerSamples(predicate: NSPredicate) async -> [HKQuantitySample] {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return []
        }
        
        return await withCheckedContinuation { continuation in
            let powerType = HKQuantityType(.runningPower)
            let powerQuery = HKSampleQuery(sampleType: powerType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
                guard error == nil, let powerSamples = samples as? [HKQuantitySample] else {
                    logger.error("Error fetching power samples: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: powerSamples)
            }
            
            healthStore.execute(powerQuery)
        }
    }
    
    // MARK: - Compute Average Data
    
    private func calculateLastRunStats() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.calculateLastRunAverageHeartRate()
            }
            group.addTask {
                await self.calculateLastRunAverageCadence()
            }
            group.addTask {
                await self.calculateLastRunAveragePower()
            }
        }
    }
    
    private func calculateLastRunAverageHeartRate() async {
        guard let workout = lastWorkout?.workout else {
            logger.error("No workout available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [.strictStartDate, .strictEndDate])
        
        let heartRateSamples = await fetchHeartRateSamples(predicate: predicate)
        
        guard !heartRateSamples.isEmpty else {
            logger.warning("No heart rate samples available.")
            return
        }
        
        let heartRates = heartRateSamples.map { $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) }
        let totalHeartRate = heartRates.reduce(0, +)
        let averageHeartRate = totalHeartRate / Double(heartRates.count)
        
        Task { @MainActor in
            self.lastWorkout?.setAverageHeartRate(averageHeartRate)
        }
    }
    
    private func calculateLastRunAverageCadence() async {
        guard let workout = lastWorkout?.workout else {
            logger.error("No workout available.")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [.strictStartDate, .strictEndDate])
        
        let stepSamples = await fetchStepCountSamples(predicate: predicate)
        
        guard !stepSamples.isEmpty else {
            logger.warning("No step count samples available.")
            return
        }
        
        var totalSteps = 0.0
        var totalTime: TimeInterval = 0.0
        
        for sample in stepSamples {
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            let sampleDuration = sample.endDate.timeIntervalSince(sample.startDate)
            
            totalSteps += steps
            totalTime += sampleDuration
        }
        
        let averageCadence = (totalSteps / totalTime) * 60.0
        
        Task { @MainActor in
            self.lastWorkout?.setAverageCadence(averageCadence)
        }
    }
    
    private func calculateLastRunAveragePower() async {
        guard let workout = lastWorkout?.workout else {
            logger.warning("No workout available.")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [.strictStartDate, .strictEndDate])
        
        let powerSamples = await fetchPowerSamples(predicate: predicate)
        
        guard !powerSamples.isEmpty else {
            logger.warning("No power samples available.")
            return
        }
        
        let powers = powerSamples.map { $0.quantity.doubleValue(for: HKUnit.watt()) }
        let totalPower = powers.reduce(0, +)
        
        let averagePower = totalPower / Double(powers.count)
        
        Task { @MainActor in
            self.lastWorkout?.setAveragePower(averagePower)
        }
    }
    
    // MARK: - Helper Methods
    
    func getWorkout(forID workoutID: UUID) -> HKWorkout? {
        if let workout = self.workouts.first(where: { $0.id == workoutID } ) {
            return workout
        }
        
        return nil
    }
    
    func getWorkouts(forIDs workoutIDs: [UUID]) -> [HKWorkout] {
        let filteredWorkouts = workouts.filter { workout in
            return workoutIDs.contains { $0 == workout.id }
        }
        
        return filteredWorkouts.sorted { $0.endDate > $1.endDate }
    }
    
    func getLastRun() -> RunningWorkout? {
        return lastWorkout
    }
    
    func updateLatestUpdateDate(from workoutIDs: [UUID]) {
        let workouts = getWorkouts(forIDs: workoutIDs)
        
        guard !workouts.isEmpty else { return }
        
        if let mostRecentEndDate = workouts.map(\.endDate).max(), mostRecentEndDate > self.latestUpdate {
            self.latestUpdate = mostRecentEndDate
            logger.debug("latestUpdate date updated to \(self.latestUpdate)")
        }
    }
}
