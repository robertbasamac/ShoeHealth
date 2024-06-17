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
                                                     options: [],
                                                     icon: UNNotificationActionIcon(systemImageName: "shoe.2"))
        
        let remindMeLater = UNNotificationAction(identifier: "REMIND_ME_LATER",
                                                 title: "Remind me later",
                                                 options: [],
                                                 icon: UNNotificationActionIcon(systemImageName: "clock.arrow.circlepath"))
        
        let runningWorkoutCategory = UNNotificationCategory(identifier: "NEW_RUNNING_WORKOUT_AVAILABLE",
                                                            actions: [defaultShoeAction, remindMeLater],
                                                            intentIdentifiers: [],
                                                            hiddenPreviewsBodyPlaceholder: "preview placeholder",
                                                            categorySummaryFormat: "format summary",
                                                            options: [.customDismissAction])
        
        center.setNotificationCategories([runningWorkoutCategory])
    }
    
    func scheduleNotification(workout: HKWorkout, dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
        
        let distanceString = distanceFormatter.string(fromValue: workout.totalDistance(unitPrefix: .kilo), unit: .kilometer)
        let dateString = workout.endDate.formatted(date: .numeric, time: .shortened)
        
        content.title = "New Running Workout"
        content.subtitle = "\(distanceString), \(dateString)"
        content.sound = .default
        content.body = "Tap on this notification to manually choose your shoe or long press on it to see the options."
        content.userInfo = ["WORKOUT_ID" : workout.id.uuidString]
        content.categoryIdentifier = "NEW_RUNNING_WORKOUT_AVAILABLE"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        if let date = Calendar.current.date(from: dateComponents) {
            logger.debug("Notification scheduled: \(dateTimeFormatter.string(from: date))")
        }            
    }
}
