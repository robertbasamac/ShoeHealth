//
//  HealthKitManager.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import Foundation
import HealthKit
import Observation
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "HealthKitManager")

@Observable
final class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    @ObservationIgnored private var healthStore = HKHealthStore()
    
    @ObservationIgnored private var readTypes: Set = [.workoutType(), HKSeriesType.workoutType()]
    @ObservationIgnored private let sampleType =  HKObjectType.workoutType()
    @ObservationIgnored private let predicate = HKQuery.predicateForWorkouts(with: .running)
    
    @ObservationIgnored @UserDefault("latestUpdate", defaultValue: Date.distantPast) static var latestUpdate: Date
    
    private(set) var workouts: [HKWorkout] = []
    
    private init() { }
    
    // MARK: - Request HealthKit authorization
    
    func requestHealthKitAuthorization() async {
        if !HKHealthStore.isHealthDataAvailable() {
            logger.warning("HealthKit not accessable.")
            return
        }
       
        var status: String = ""

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)

            status = "HealthKit authorization request was successful!"
            
            await self.fetchRunningWorkouts()
            await self.startObservingNewWorkouts()
        } catch {
            status = "HealthKit Authorization Error: \(error.localizedDescription)"
        }
        
        logger.info("\(status)")
    }
    
    // MARK: - Fetching Running Workouts
    
    func fetchRunningWorkouts() async {
        if !HKHealthStore.isHealthDataAvailable() {
            logger.warning("HealthKit not accessable.")
            return;
        }

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKSampleQuery(sampleType: sampleType,
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
            }))
        }
        
        guard let workouts = samples as? [HKWorkout] else {
            logger.warning("Did not manage to convert HKSample to HKWorkout.")
            return
        }
        
        logger.debug("\(workouts.count) workouts fetched.")
        
        Task { @MainActor in
            self.workouts = workouts
        }
    }
    
    // MARK: - Observing new Workouts
    
    private func startObservingNewWorkouts() async {
        if !HKHealthStore.isHealthDataAvailable() {
            logger.warning("HealthKit not accessable.")
            return
        }
        
        let query = HKObserverQuery(sampleType: sampleType, predicate: predicate) { (query, completionHandler, error) in
            if let error = error {
                logger.warning("HKObserverQuery returned error, \(error).")
                return
            }
            
            self.handleNewWorkouts { completionHandler() }
        }
        
        self.healthStore.execute(query)
        
        do {
            try await healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate)
            logger.info("Background delivery enabled.")
        } catch {
            logger.warning("Could not enable background delivery, \(error.localizedDescription).")
        }
    }
    
    private func handleNewWorkouts(completionHandler: @escaping () -> Void) {
        var anchor: HKQueryAnchor?
        
        let anchoredQuery = HKAnchoredObjectQuery(type: sampleType,
                                                  predicate: predicate,
                                                  anchor: anchor,
                                                  limit: HKObjectQueryNoLimit) { [unowned self] query, newSamples, deletedSamples, newAnchor, error in
            self.updateWorkouts(newSamples: newSamples ?? [], deletedObjects: deletedSamples ?? [])
            anchor = newAnchor
            
            completionHandler()
        }
        
        healthStore.execute(anchoredQuery)
    }

    private func updateWorkouts(newSamples: [HKSample], deletedObjects: [HKDeletedObject]) {
        guard let newWorkout = newSamples.last as? HKWorkout else {
            logger.warning("Did not manage to convert HKSample to HKWorkout.")
            return
        }

        logger.debug("New workout received: \(dateFormatter.string(from: newWorkout.endDate)) - \(String(format: "%.2f Km", newWorkout.totalDistance(unitPrefix: .kilo))).")
        
        if HealthKitManager.latestUpdate < newWorkout.endDate && !self.workouts.contains(where: { $0.id == newWorkout.id }) {
            let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? .now)
            
            NotificationManager.shared.scheduleNotification(workout: newWorkout, dateComponents: dateComponents)
            HealthKitManager.latestUpdate = newWorkout.endDate
            
            self.workouts.append(newWorkout)
        } else {
            logger.debug("This is an old workout. A custom in app notification will be triggered for this workout (if not assgined already) when user opens the app.")
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
}
