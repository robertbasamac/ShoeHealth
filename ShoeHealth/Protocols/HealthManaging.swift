//
//  HealthManaging.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 02.07.2025.
//


import Foundation
import HealthKit

protocol HealthManaging {
    
    var workouts: [HKWorkout] { get }
    var lastWorkout: RunningWorkout? { get }
    var isLoading: Bool { get }
    var isFetchingWorkouts: Bool { get set }
    var latestUpdate: Date { get set }

    func requestHealthAuthorization() async -> Bool
    func startObserving()
    func fetchRunningWorkouts() async
    func fetchDistanceSamples(for workout: HKWorkout, completion: @Sendable @escaping ([HKQuantitySample]) -> Void)
    func getWorkout(forID workoutID: UUID) -> HKWorkout?
    func getWorkouts(forIDs workoutIDs: [UUID]) -> [HKWorkout]
    func getLastRun() -> RunningWorkout?
    func updateLatestUpdateDate(from workoutIDs: [UUID])
}
