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

@Observable
final class HealthManager {
    
    static let shared = HealthManager()
    
    @ObservationIgnored private var healthStore = HKHealthStore()
    
    @ObservationIgnored private let readTypes: Set = [HKObjectType.workoutType(),
                                                      HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!]
    @ObservationIgnored private let sampleType =  HKObjectType.workoutType()
    @ObservationIgnored private let predicate = HKQuery.predicateForWorkouts(with: .running)
    
    @ObservationIgnored @UserDefault("latestUpdate", defaultValue: Date.distantPast) var latestUpdate: Date
    
    private(set) var workouts: [HKWorkout] = []
    
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
            logger.warning("HealthKit not accessable.")
            return
        }
        
        do {
            try await healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate)
            
            logger.info("Background delivery enabled.")
            
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
        guard let newWorkout = newSamples.last as? HKWorkout else {
            logger.warning("Did not manage to convert HKSample to HKWorkout.")
            return
        }

        logger.debug("New workout received: \(dateTimeFormatter.string(from: newWorkout.endDate)) - \(String(format: "%.2f Km", newWorkout.totalDistance(unitPrefix: .kilo))).")
        
        if self.latestUpdate < newWorkout.endDate && !self.workouts.contains(where: { $0.id == newWorkout.id }) {
            let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? .now)
            
            NotificationManager.shared.scheduleNewWorkoutNotification(forNewWorkout: newWorkout, at: dateComponents)
            self.latestUpdate = newWorkout.endDate
        } else {
            logger.debug("This is an old workout. A custom in app notification will be triggered for this workout (if not assgined already) when user opens the app.")
        }
        
        Task {
            await self.fetchRunningWorkouts()
        }
    }
    
    // MARK: - Handling HealthKit Data
        
    func fetchRunningWorkouts() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return
        }

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            let query = HKSampleQuery(sampleType: sampleType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [.init(keyPath: \HKSample.endDate, ascending: false)],
                                      resultsHandler: { query, samples, error in
                if let unwrappedError = error {
                    continuation.resume(throwing: unwrappedError)
                    return
                }
                
                guard let samples = samples else {
                    logger.error("HealthKit not accessable.")
                    fatalError("Invalid State: This can only fail if there was an error.")
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
            HealthManager.shared.workouts = workouts
        }
    }
    
    func fetchDistanceSamples(for workout: HKWorkout, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.warning("HealthKit is not available on this device.")
            return
        }
        
        let sampleType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
            if let samples = results as? [HKQuantitySample] {
                completion(samples)
            } else {
                completion([])
            }
        }
        
        healthStore.execute(query)
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
    
    func getLastRun() -> HKWorkout? {
        return workouts.first
    }
}
