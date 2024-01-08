//
//  AppDelegate.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.12.2023.
//

import Foundation
import UIKit

class AppDelegate: NSObject {
    
    var app: ShoeHealthApp?
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
    
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
        
        guard let workoutID = userInfo["WORKOUT_ID"] as? String, let workout = HealthKitManager.shared.getWorkout(forID: workoutID) else { return }
        
        switch response.actionIdentifier {
        case "DEFAULT_SHOE_ACTION":
            if let shoe = app?.shoesViewModel.getDefaultShoe() {
                shoe.workouts.append(workout.id)
                shoe.currentDistance += workout.totalDistance(unitPrefix: .kilo)
            }
            
        case "REMIND_ME_LATER":
            var dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: .now)
            dateComponents.second? += 3 // TODO: to update to "hour? += 1"
            
            NotificationManager.shared.scheduleNotification(workout: workout, dateComponents: dateComponents)
            
        case UNNotificationDefaultActionIdentifier:
            app?.navigationRouter.workout = workout
            
        default:
            break
        }
        
        completionHandler()
    }
}
