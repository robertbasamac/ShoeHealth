//
//  AppDelegate.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.12.2023.
//

import Foundation
import UIKit
import HealthKit

// MARK: - UIApplicationDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let healthManager = HealthKitManager.shared
        healthManager.requestHealthKitAuthorization()
        
        let notificationManager = NotificationManager.shared
        notificationManager.requestAuthorization()
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let workoutID = userInfo["WORKOUT_ID"] as? String
        
        switch response.actionIdentifier {
        case "DEFAULT_SHOE_ACTION":
            print("Default shoe added.")
            
            NotificationManager.shared.cancelNotification()
        case "REMIND_ME_LATER":
            print("Remind me later.")
            
            guard let workoutID = workoutID else { return }
            guard let workout = HealthKitManager.shared.getWorkout(forID: workoutID) else { return }
            
            var dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: .now)
            dateComponents.second? += 3 // TODO: to update to "hour? += 1"
            
            NotificationManager.shared.scheduleNotification(workout: workout, dateComponents: dateComponents)
        default:
            break
        }
        
        completionHandler()
    }
}
