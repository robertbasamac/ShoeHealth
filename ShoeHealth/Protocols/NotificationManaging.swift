//
//  NotificationManaging.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 07.07.2025.
//

import Foundation
import UserNotifications
import HealthKit

protocol NotificationManaging: Sendable {
    
    var notificationAuthorizationStatus: UNAuthorizationStatus { get set }
    func requestNotificationAuthorization() async -> Bool
    func retrieveNotificationAuthorizationStatus() async
    func setActionableNotificationTypes(isPremiumUser: Bool)
    func scheduleNewWorkoutNotification(forNewWorkouts workouts: [HKWorkout], at dateComponents: DateComponents)
    func scheduleShoeWearNotification(forShoe shoe: Shoe, at dateComponents: DateComponents)
    func scheduleSetDefaultShoeNotification(for: [RunType], at dateComponents: DateComponents)
    func openSettings() async
    func getBadge() -> String
}
