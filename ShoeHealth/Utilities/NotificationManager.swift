//
//  NotificationManager.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.12.2023.
//

import Foundation
import UserNotifications
import HealthKit

class NotificationManager {
        
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if success {
                print("Notifications authorized.")
            } else {
                if let unwrappedError = error {
                    print("ERROR: \(unwrappedError.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleNotification(workout: HKWorkout) {
        let content = UNMutableNotificationContent()
        
        content.title = "New Running Workout"
        content.subtitle = "\(workout.endDate.formatted(date: .abbreviated, time: .shortened))"
        content.sound = .default

        content.body = """
                       A new Running Workout of \(distanceFormatter.string(fromValue: workout.totalDistance(unitPrefix: .kilo), unit: .kilometer)) is available.
                       Tap on this notification to choose your shoe pair for this run.
                       """
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: .now)
        dateComponents.second? += 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
