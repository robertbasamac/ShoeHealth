//
//  AppDelegate.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.12.2023.
//

import Foundation
import UIKit
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "AppDelegate")

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
        
        guard let workoutID = userInfo["WORKOUT_ID"] as? String, let workout = HealthKitManager.shared.getWorkout(forID: UUID(uuidString: workoutID) ?? UUID()) else { return }
        
        switch response.actionIdentifier {
        case "DEFAULT_SHOE_ACTION":
            logger.debug("\"Use default shoe\" action pressed.")
            
            if let shoe = app?.shoesViewModel.getDefaultShoe() {
                app?.shoesViewModel.add(workoutIDs: [workout.id], toShoe: shoe.id)                
            }
        
        case "REMIND_ME_LATER":
            logger.debug("\"Remind me later\" action pressed.")

            let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
            let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date ?? .now)
            
            NotificationManager.shared.scheduleNotification(workout: workout, dateComponents: dateComponents)
            
        case UNNotificationDefaultActionIdentifier:
            app?.navigationRouter.workout = workout
        
        default:
            break
        }
        
        completionHandler()
    }
}
