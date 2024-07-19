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

    private init() { }
    
    func requestNotificationAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            
            logger.info("Notifications authorized.")
            
            return granted
        } catch {
            return false
        }
    }
    
    func getNotificationAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
            
//        if settings.authorizationStatus == .authorized {
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
        
        return settings.authorizationStatus
    }
    
    func setActionableNotificationTypes() {
        let defaultShoeAction = UNNotificationAction(identifier: "DEFAULT_SHOE_ACTION",
                                                     title: "Use default Shoe",
                                                     options: [.authenticationRequired],
                                                     icon: UNNotificationActionIcon(systemImageName: "shoe.2"))
        
        let remindMeLaterAction = UNNotificationAction(identifier: "REMIND_ME_LATER",
                                                       title: "Remind me later",
                                                       options: [.authenticationRequired],
                                                       icon: UNNotificationActionIcon(systemImageName: "clock.arrow.circlepath"))
        
        let runningWorkoutCategory = UNNotificationCategory(identifier: "NEW_RUNNING_WORKOUT_AVAILABLE",
                                                            actions: [defaultShoeAction, remindMeLaterAction],
                                                            intentIdentifiers: [],
                                                            hiddenPreviewsBodyPlaceholder: "preview placeholder",
                                                            categorySummaryFormat: "format summary",
                                                            options: [.customDismissAction])
        
        let retireShoeAction = UNNotificationAction(identifier: "RETIRE_SHOE_ACTION",
                                                    title: "Retire Shoe",
                                                    options: [.authenticationRequired, .destructive],
                                                    icon: UNNotificationActionIcon(systemImageName: "bolt.slash.fill"))
        
        let wearUpdateCategory = UNNotificationCategory(identifier: "SHOE_WEAR_UPDATE",
                                                        actions: [retireShoeAction],
                                                        intentIdentifiers: [],
                                                        hiddenPreviewsBodyPlaceholder: "preview placeholder",
                                                        categorySummaryFormat: "format summary",
                                                        options: [.customDismissAction])
        
        center.setNotificationCategories([runningWorkoutCategory, wearUpdateCategory])
    }
    
    func scheduleNewWorkoutNotification(forNewWorkout workout: HKWorkout, at dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
        
        let distanceString = distanceFormatter.string(fromValue: workout.totalDistance(unitPrefix: .kilo), unit: .kilometer)
        let dateString = workout.endDate.formatted(date: .numeric, time: .shortened)
        
        content.title = "New Running Workout"
        content.subtitle = "\(distanceString), \(dateString)"
        content.sound = .default
        content.body = "A new running workout has been logged. Tap on this notification to select your shoe manually, or long press to view available options."
        content.userInfo = ["WORKOUT_ID" : workout.id.uuidString]
        content.categoryIdentifier = "NEW_RUNNING_WORKOUT_AVAILABLE"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        if let date = Calendar.current.date(from: dateComponents) {
            logger.debug("New Workout Notification scheduled: \(dateTimeFormatter.string(from: date))")
        }            
    }
    
    func scheduleShoeWearNotification(forShoe shoe: Shoe, at dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
          
        content.title = "Shoe Wear Update"
        content.subtitle = "Shoe wear is now \(shoe.wearType.name)."
        content.sound = .default
        content.body = "\"\(shoe.brand) \(shoe.model)\" - \(shoe.wearType.description) \(shoe.wearType.action) Tap on this notification to manually check the shoe."
        content.userInfo = ["SHOE_ID" : shoe.id.uuidString]
        content.categoryIdentifier = "SHOE_WEAR_UPDATE"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        if let date = Calendar.current.date(from: dateComponents) {
            logger.debug("Wear Noification scheduled: \(dateTimeFormatter.string(from: date))")
        }
    }
    
    func scheduleSetDefaultShoeNotification(at dateComponents: DateComponents) {
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
}
    
