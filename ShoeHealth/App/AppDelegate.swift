//
//  AppDelegate.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.12.2023.
//

import UIKit
import WidgetKit
import OSLog
import SwiftUI

private let logger = Logger(subsystem: "Shoe Health", category: "AppDelegate")

class AppDelegate: NSObject {
    
    var shoesViewModel: ShoesViewModel?
    var navigationRouter: NavigationRouter?
    
    @AppStorage("IS_ONBOARDING") var isOnboarding: Bool = true
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
        
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        if categoryIdentifier == "NEW_RUNNING_WORKOUT_AVAILABLE" {
            guard let stringWorkoutID = userInfo["WORKOUT_ID"] as? String, let workout = HealthManager.shared.getWorkout(forID: UUID(uuidString: stringWorkoutID) ?? UUID()) else { return }
            
            switch response.actionIdentifier {
            case "DEFAULT_SHOE_ACTION":
                logger.debug("\"Use default shoe\" action pressed.")
                
                if let shoe = shoesViewModel?.getDefaultShoe() {
                    shoesViewModel?.add(workoutIDs: [workout.id], toShoe: shoe.id)
                }
                break
                
            case "REMIND_ME_LATER":
                logger.debug("\"Remind me later\" action pressed.")
                
                let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
                let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date ?? .now)
                
                NotificationManager.shared.scheduleNewWorkoutNotification(forNewWorkout: workout, at: dateComponents)
                break
                
            case UNNotificationDefaultActionIdentifier:
                navigationRouter?.showSheet = .addToShoe(workoutID: workout.id)
                break
                
            default:
                break
            }
        } else if categoryIdentifier == "SHOE_WEAR_UPDATE" {
            guard let stringShoeID = userInfo["SHOE_ID"] as? String, let shoeID = UUID(uuidString: stringShoeID) else { return }
            
            switch response.actionIdentifier {
            case "RETIRE_SHOE_ACTION":
                logger.debug("\"Retire Shoe\" action pressed.")
                
                guard let shoe = shoesViewModel?.getShoe(forID: shoeID) else { break }
                                
                let wasDefaultShoe = shoe.isDefaultShoe
                
                shoesViewModel?.retireShoe(shoeID)
                                
                if wasDefaultShoe && shoe.isRetired {
                    logger.debug("Scheduling Set New Default Shoe notification")
                    
                    let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
                    let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date ?? .now)
                    
                    NotificationManager.shared.scheduleSetDefaultShoeNotification(at: dateComponents)
                }
                break
                
            case UNNotificationDefaultActionIdentifier:
                guard let shoe = shoesViewModel?.getShoe(forID: shoeID) else { break }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationRouter?.showShoeDetails = shoe
                }
                break
                
            default:
                break
            }
        } else if categoryIdentifier == "SET_DEFAULT_SHOE" {
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationRouter?.showSheet = .setDefaultShoe
                }
                break
                
            default:
                break
            }
        }
        
        completionHandler()
    }
}
