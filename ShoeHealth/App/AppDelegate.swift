//
//  AppDelegate.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.12.2023.
//

import UIKit
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "AppDelegate")

class AppDelegate: NSObject {
    
    var shoesViewModel: ShoesViewModel?
    var navigationRouter: NavigationRouter?
    
    @UserDefault("isOnboarding", defaultValue: true) var isOnboarding: Bool
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {       
        UNUserNotificationCenter.current().delegate = self
        
        NotificationManager.shared.setActionableNotificationTypes()
            
        if !isOnboarding {
            HealthManager.shared.startObserving()
        }
        
        return true
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let workoutID = userInfo["WORKOUT_ID"] as? String, let workout = HealthManager.shared.getWorkout(forID: UUID(uuidString: workoutID) ?? UUID()) else { return }
        
        switch response.actionIdentifier {
        case "DEFAULT_SHOE_ACTION":
            logger.debug("\"Use default shoe\" action pressed.")
            
            if let shoe = shoesViewModel?.getDefaultShoe() {
                shoesViewModel?.add(workoutIDs: [workout.id], toShoe: shoe.id)
            }
        
        case "REMIND_ME_LATER":
            logger.debug("\"Remind me later\" action pressed.")

            let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
            let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date ?? .now)
            
            NotificationManager.shared.scheduleNotification(workout: workout, dateComponents: dateComponents)
            
        case UNNotificationDefaultActionIdentifier:
            navigationRouter?.workout = workout
        
        default:
            break
        }
        
        completionHandler()
    }
}
