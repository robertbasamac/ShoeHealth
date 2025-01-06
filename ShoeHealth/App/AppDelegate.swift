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
        HealthManager.shared.startObserving()
        
        return true
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        if categoryIdentifier == "NEW_RUNNING_WORKOUT_AVAILABLE" {
            guard let stringWorkoutID = userInfo["WORKOUT_ID"] as? String,
                  let workoutID =  UUID(uuidString: stringWorkoutID)
            else { return }
            
            switch response.actionIdentifier {
            case "DEFAULT_SHOE_ACTION_DAILY":
                logger.debug("\"Use Daily Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: [workoutID])
                
                break
                
            case "DEFAULT_SHOE_ACTION_TEMPO":
                logger.debug("\"Use Tempo Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: [workoutID])
                
                break
                
            case "DEFAULT_SHOE_ACTION_LONG":
                logger.debug("\"Use Long Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: [workoutID])
                
                break
                
            case "DEFAULT_SHOE_ACTION_RACE":
                logger.debug("\"Use Race default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: [workoutID])
                
                break
                
            case "DEFAULT_SHOE_ACTION_TRAIL":
                logger.debug("\"Use Train Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: [workoutID])
                
                break
                
            case "REMIND_ME_LATER":
                logger.debug("\"Remind me later\" action pressed.")
                
                handleRemindMeLaterAction(forWorkoutIDs: [workoutID])
                break
                
            case UNNotificationDefaultActionIdentifier:
                logger.debug("\"New Running Workout\" notification pressed.")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationRouter?.showSheet = .addWorkoutToShoe(workoutID: workoutID)
                }
                break
                
            default:
                break
            }
        } else if categoryIdentifier == "MULTIPLE_NEW_RUNNING_WORKOUTS_AVAILABLE" {
            logger.debug("MULTIPLE_NEW_RUNNING_WORKOUTS_AVAILABLE notification.")

            guard let stringWorkoutIDs = userInfo["WORKOUT_IDs"] as? [String] else { return }

            let workoutIDs = stringWorkoutIDs.compactMap { UUID(uuidString: $0) }

            guard !workoutIDs.isEmpty else { return }
                        
            switch response.actionIdentifier {
            case "DEFAULT_SHOE_ACTION_DAILY":
                logger.debug("\"Use Daily Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: workoutIDs)
                
                break
                
            case "DEFAULT_SHOE_ACTION_TEMPO":
                logger.debug("\"Use Tempo Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: workoutIDs)
                
                break
                
            case "DEFAULT_SHOE_ACTION_LONG":
                logger.debug("\"Use Long Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: workoutIDs)
                
                break
                
            case "DEFAULT_SHOE_ACTION_RACE":
                logger.debug("\"Use Race default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: workoutIDs)
                
                break
                
            case "DEFAULT_SHOE_ACTION_TRAIL":
                logger.debug("\"Use Train Run default shoe\" action pressed.")
                
                handleDefaultShoeAction(for: .daily, forWorkoutIDs: workoutIDs)
                
                break
                
            case "REMIND_ME_LATER":
                logger.debug("\"Remind me later\" action pressed.")
                
                handleRemindMeLaterAction(forWorkoutIDs: workoutIDs)
                break
                
            case UNNotificationDefaultActionIdentifier:
                logger.debug("\"Multiple New Running Workouts\" notification pressed.")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationRouter?.showSheet = .addMultipleWorkoutsToShoe(workoutIDs: workoutIDs)
                }
                break
                
            default:
                break
            }
        } else if categoryIdentifier == "SHOE_WEAR_UPDATE" {
            guard let stringShoeID = userInfo["SHOE_ID"] as? String, let shoeID = UUID(uuidString: stringShoeID) else { return }
            
            switch response.actionIdentifier {
            case "RETIRE_SHOE_ACTION":
                logger.debug("\"Retire Shoe\" action pressed.")
                
                handleRetireShoeAction(forShoeID: shoeID)
                break
                
            case UNNotificationDefaultActionIdentifier:
                logger.debug("\"Show Wear Update\" notification pressed.")

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
                logger.debug("\"Set Default Shoe\" notification pressed.")
                
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
    
    private func handleDefaultShoeAction(for runType: RunType, forWorkoutIDs workoutIDs: [UUID]) {
        if let shoe = shoesViewModel?.getDefaultShoe(for: runType) {
            Task {
                await shoesViewModel?.add(workoutIDs: workoutIDs, toShoe: shoe.id)
            }
        }
    }
    
    private func handleRemindMeLaterAction(forWorkoutIDs workoutIDs: [UUID]) {
        let date: Date?
        let remindMeLaterTime = SettingsManager.shared.remindMeLaterTime
        
        switch remindMeLaterTime.duration.unit {
        case .minute, .minutes:
            date = Calendar.current.date(byAdding: .minute, value: remindMeLaterTime.duration.value, to: .now)
        case .hour, .hours:
            date = Calendar.current.date(byAdding: .hour, value: remindMeLaterTime.duration.value, to: .now)
        case .day, .days:
            date = Calendar.current.date(byAdding: .day, value: remindMeLaterTime.duration.value, to: .now)
        }
                        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? .now)
        
        let workouts = HealthManager.shared.getWorkouts(forIDs: workoutIDs)
        
        NotificationManager.shared.scheduleNewWorkoutNotification(forNewWorkouts: workouts, at: dateComponents)
    }
    
    private func handleRetireShoeAction(forShoeID shoeID: UUID) {
        guard let shoe = shoesViewModel?.getShoe(forID: shoeID) else { return }
        
        let setNewDefaultShoe = !shoe.defaultRunTypes.isEmpty && !shoe.isRetired
        
        shoesViewModel?.retireShoe(shoeID)
        
        if setNewDefaultShoe {
            logger.debug("Scheduling Set New Default Shoe notification")
            
            let date = Calendar.current.date(byAdding: .second, value: 5, to: .now)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? .now)
            
            NotificationManager.shared.scheduleSetDefaultShoeNotification(at: dateComponents)
        }
    }
}
