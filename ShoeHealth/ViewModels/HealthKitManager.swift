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
    var isAuthorized: Bool = false
    
    var workouts: [HKWorkout] = []
    
    func requestPermission () async -> Bool {
        let read: Set = [
            .workoutType(),
            HKSeriesType.workoutType()
        ]

        let res: ()? = try? await healthStore.requestAuthorization(toShare: [], read: read)
        guard res != nil else {
            return false
        }

        return true
    }
    
    func readRunningWorkouts() async {
        let running = HKQuery.predicateForWorkouts(with: .running)

        let samples = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKSampleQuery(sampleType: .workoutType(),
                                              predicate: running,
                                              limit: HKObjectQueryNoLimit,
                                              sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)],
                                              resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }
                
                guard let samples = samples else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }

                continuation.resume(returning: samples)
            }))
        }

        print("samples received: \(samples.count)")
        guard let workouts = samples as? [HKWorkout] else {
            print("not managed to convert to HKWorkout")
            return
        }
        
        self.workouts = workouts
    }
}
