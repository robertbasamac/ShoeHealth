//
//  NotificationManager.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.12.2023.
//

import Foundation
import UserNotifications
import HealthKit
import UIKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "NotificationManager")

final class NotificationManager {
        
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    private let options: UNAuthorizationOptions = [.alert, .sound, .badge]

    var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await retrieveNotificationAuthorizationStatus()
        }
    }
    
    func requestNotificationAuthorization() async -> Bool {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            
            await retrieveNotificationAuthorizationStatus()
            
            switch notificationAuthorizationStatus {
            case .notDetermined:
                logger.debug("Notifications not determined.")
            case .denied:
                logger.debug("Notifications denied.")
            case .authorized:
                logger.debug("Notifications authorized.")
            case .provisional:
                logger.debug("Notifications provisional.")
            case .ephemeral:
                logger.debug("Notifications ephemeral.")
            @unknown default:
                logger.debug("Notifications status unknown.")
            }
            
            return true
        } catch {
            return false
        }
    }
    
    @MainActor
    func retrieveNotificationAuthorizationStatus() async {
        let settings = await center.notificationSettings()
            
//        if settings.authorizationStatus == .authorized {
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
        
        self.notificationAuthorizationStatus = settings.authorizationStatus
    }
    
    func setActionableNotificationTypes() {
        logger.debug("Setting up actionable notifications.")
        
        // actions
        let defaultShoeActionDaily = UNNotificationAction(
            identifier: "DEFAULT_SHOE_ACTION_DAILY",
            title: "Use default Shoe - Daily",
            options: [.authenticationRequired],
            icon: UNNotificationActionIcon(systemImageName: "shoe.2")
        )
        
        let defaultShoeActionTempo = UNNotificationAction(
            identifier: "DEFAULT_SHOE_ACTION_TEMPO",
            title: "Use default Shoe - Tempo",
            options: [.authenticationRequired],
            icon: UNNotificationActionIcon(systemImageName: "shoe.2")
        )
        
        let defaultShoeActionLong = UNNotificationAction(
            identifier: "DEFAULT_SHOE_ACTION_LONG",
            title: "Use default Shoe - Long",
            options: [.authenticationRequired],
            icon: UNNotificationActionIcon(systemImageName: "shoe.2")
        )
        
        let defaultShoeActionRace = UNNotificationAction(
            identifier: "DEFAULT_SHOE_ACTION_DAILY_RACE",
            title: "Use default Shoe - Race",
            options: [.authenticationRequired],
            icon: UNNotificationActionIcon(systemImageName: "shoe.2")
        )
        
        let defaultShoeActionTrail = UNNotificationAction(
            identifier: "DEFAULT_SHOE_ACTION_TRAIL",
            title: "Use default Shoe - Trail",
            options: [.authenticationRequired],
            icon: UNNotificationActionIcon(systemImageName: "shoe.2")
        )
        
        let remindMeLaterAction = UNNotificationAction(
            identifier: "REMIND_ME_LATER",
            title: "Remind me later",
            options: [.authenticationRequired],
            icon: UNNotificationActionIcon(systemImageName: "clock.arrow.circlepath")
        )
        
        let retireShoeAction = UNNotificationAction(
            identifier: "RETIRE_SHOE_ACTION",
            title: "Retire Shoe",
            options: [.authenticationRequired, .destructive],
            icon: UNNotificationActionIcon(systemImageName: "bolt.slash.fill")
        )
        
        // categories
        let runningWorkoutCategory = UNNotificationCategory(
            identifier: "NEW_RUNNING_WORKOUT_AVAILABLE",
            actions: [
                defaultShoeActionDaily,
                defaultShoeActionTempo,
                defaultShoeActionLong,
                defaultShoeActionRace,
                defaultShoeActionTrail,
                remindMeLaterAction
            ],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "%u New Workout(s) logged",
            categorySummaryFormat: "There are %u new workouts.",
            options: [.customDismissAction]
        )
        
        let multipleRunningWorkoutsCategory = UNNotificationCategory(
            identifier: "MULTIPLE_NEW_RUNNING_WORKOUTS_AVAILABLE",
            actions: [
                defaultShoeActionDaily,
                defaultShoeActionTempo,
                defaultShoeActionLong,
                defaultShoeActionRace,
                defaultShoeActionTrail,
                remindMeLaterAction
            ],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "New Workouts logged",
            categorySummaryFormat: "There are %u new workouts.",
            options: [.customDismissAction]
        )
        
        let wearUpdateCategory = UNNotificationCategory(
            identifier: "SHOE_WEAR_UPDATE",
            actions: [retireShoeAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Shoe wear update",
            categorySummaryFormat: "There are %u shoe wear updates.",
            options: [.customDismissAction]
        )
        
        center.setNotificationCategories([runningWorkoutCategory, multipleRunningWorkoutsCategory, wearUpdateCategory])
    }
    
    func scheduleNewWorkoutNotification(forNewWorkouts workouts: [HKWorkout], at dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
        
        logger.debug("Scheduling new workout notifications for \(workouts.count) workouts.")
        
        let unitOfMeasure = SettingsManager.shared.unitOfMeasure
        
        if workouts.count == 1, let workout = workouts.first {
            let distanceString = String(format: "%.2f\(unitOfMeasure.symbol)", workout.totalDistance(unit: unitOfMeasure.unit))
            let dateString = workout.endDate.formatted(date: .numeric, time: .shortened)
            
            content.title = "New Running Workout"
            content.subtitle = "\(distanceString), \(dateString)"
            content.sound = .default
            content.body = "A new running workout has been logged. Tap on this notification to manually select your shoe or long press to check available options."
            content.userInfo = ["WORKOUT_ID" : workout.id.uuidString]
            content.categoryIdentifier = "NEW_RUNNING_WORKOUT_AVAILABLE"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        } else {
            let workoutIDs = workouts.map { $0.uuid.uuidString }
            
            content.title = "New Running Workouts"
            content.subtitle = "\(workouts.count) workouts available"
            content.sound = .default
            content.body = "Tap on this notification to manually select your shoe for each workout individually or long press to check available options."
            content.userInfo = ["WORKOUT_IDs" : workoutIDs]
            content.categoryIdentifier = "MULTIPLE_NEW_RUNNING_WORKOUTS_AVAILABLE"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        
        if let date = Calendar.current.date(from: dateComponents) {
            logger.debug("New Workout Notification scheduled: \(dateTimeFormatter.string(from: date))")
        }            
    }
    
    func scheduleShoeWearNotification(forShoe shoe: Shoe, at dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
          
        content.title = "Shoe Wear Update"
        content.subtitle = "Shoe wear is now \(shoe.wearCondition.name)."
        content.sound = .default
        content.body = "\"\(shoe.brand) \(shoe.model)\" - \(shoe.wearCondition.description) \(shoe.wearCondition.action) Tap on this notification to manually check the shoe."
        content.userInfo = ["SHOE_ID" : shoe.id.uuidString]
        content.categoryIdentifier = "SHOE_WEAR_UPDATE"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        if let date = Calendar.current.date(from: dateComponents) {
            logger.debug("Wear Noification scheduled: \(dateTimeFormatter.string(from: date))")
        }
    }
    
    func scheduleSetDefaultShoeNotification(for: [RunType], at dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
          
        content.title = "Set Default Shoe"
        content.subtitle = "Default Shoe not set"
        content.sound = .default
        content.body = "Currently you have not set a Default Shoe. Tap on this notification to set one now."
        content.categoryIdentifier = "SET_DEFAULT_SHOE"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        if let date = Calendar.current.date(from: dateComponents) {
            logger.debug("Set Default Shoe Noification scheduled: \(dateTimeFormatter.string(from: date))")
        }
    }
    
    @MainActor
    func openSettings() async {
        if let appNotificationsSettingsURL = URL(string: UIApplication.openNotificationSettingsURLString), UIApplication.shared.canOpenURL(appNotificationsSettingsURL) {
            await UIApplication.shared.open(appNotificationsSettingsURL)
        }
    }
    
    func getBadge() -> String {
        switch notificationAuthorizationStatus {
        case .notDetermined:
            return ""
        case .denied:
            return "Off"
        case .authorized, .provisional, .ephemeral:
            return "On"
        @unknown default:
            return ""
        }
    }
}
    
