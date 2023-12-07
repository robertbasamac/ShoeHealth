//
//  HealthKitManager.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import Foundation
import HealthKit
import Observation

@Observable
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    var healthStore = HKHealthStore()
    var isBackgroundDeliveryEnabled: Bool = true
    
    var workouts: [HKWorkout] = []
    
    private var readTypes: Set = [.workoutType(), HKSeriesType.workoutType()]
    
    // MARK: - Request HealthKit authorization
    
    func requestHealthAuthorization() {
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit not accessable.")
            return
        }
       
        healthStore.requestAuthorization(toShare: [], read: readTypes) { (success, error) in
            var status: String = ""
            
            if let unwrappedError = error {
                status = "HealthKit Authorization Error: \(unwrappedError.localizedDescription)"
            } else {
                if success {
                    status = "HealthKit authorization request was successful!"
                    
                    Task {
                        await self.fetchRunningWorkouts()
                    }
                    DispatchQueue.main.async(execute: self.startObservingNewWorkouts)
                } else {
                    status = "HealthKit authorization did not complete successfully."
                }
            }
            
            print(status)
        }
    }
    
    // MARK: - Fetching Running Workouts
    
    func fetchRunningWorkouts() async {
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit not accessable.")
            return;
        }
        
        let sampleType =  HKObjectType.workoutType()
        let running = HKQuery.predicateForWorkouts(with: .running)

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKSampleQuery(sampleType: sampleType,
                                              predicate: running,
                                              limit: HKObjectQueryNoLimit,
                                              sortDescriptors: [.init(keyPath: \HKSample.endDate, ascending: false)],
                                              resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }
                
                guard let samples = samples else {
                    fatalError("Invalid State: This can only fail if there was an error.")
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workouts = samples as? [HKWorkout] else {
            print("Not managed to convert to HKWorkout.")
            return
        }
        
        print("\(workouts.count) workouts fetched")
        self.workouts = workouts
    }
    
    // MARK: - Observing new Workouts
    
    private func startObservingNewWorkouts() {
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit not accessable.")
            return
        }
        
        let sampleType =  HKObjectType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let query = HKObserverQuery(sampleType: sampleType, predicate: predicate) { (query, completionHandler, error) in
            self.handleNewWorkouts { completionHandler() }
        }
        
        self.healthStore.execute(query)
        
        self.healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (success, error) in
            if success {
                print("Background delivery enabled.")
                self.isBackgroundDeliveryEnabled = true
            } else {
                if let unwrappedError = error {
                    print("Could not enable background delivery, \(unwrappedError.localizedDescription).")
                }
            }
        }
    }
    
    private func handleNewWorkouts(completionHandler: @escaping () -> Void) {
        var anchor: HKQueryAnchor?
        let sampleType =  HKObjectType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .running)

        let anchoredQuery = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) { [unowned self] query, newSamples, deletedSamples, newAnchor, error in
            self.updateWorkouts(newSamples: newSamples ?? [], deletedObjects: deletedSamples ?? [])
            anchor = newAnchor
            
            completionHandler()
        }
        healthStore.execute(anchoredQuery)
    }

    private func updateWorkouts(newSamples: [HKSample], deletedObjects: [HKDeletedObject]) {
        guard let newWorkout = newSamples.last as? HKWorkout else {
            print("updateWorkouts: Not managed to convert to HKWorkout.")
            return
        }
        
        print("\(self.workouts.count) workouts available")
        if !self.workouts.contains(where: { $0.id == newWorkout.id }) {
            print("New workout received: \(newWorkout.endDate) - \(newWorkout.totalDistance(unitPrefix: .kilo)). Sending Notification.")
            NotificationManager.shared.scheduleNotification(workout: newWorkout)
            
            self.workouts.append(newWorkout)
            self.workouts = self.workouts.sorted(by: { $0.endDate > $1.endDate} )
        }
    }
}
