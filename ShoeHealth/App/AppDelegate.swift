//
//  AppDelegate.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.12.2023.
//

import Foundation
import UIKit
import HealthKit
import SwiftData

// MARK: - UIApplicationDelegate
class AppDelegate: NSObject {
    
    var container: ModelContainer = {
        let container: ModelContainer
        
        do {
            container = try ModelContainer(for: Shoe.self)
        } catch {
            fatalError("Failed to create ModelContainer for Shoe.")
        }
        
        return container
    }()
    
    var shoesViewModel: ShoesViewModel?
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        shoesViewModel = ShoesViewModel(modelContext: container.mainContext)
        
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
            guard let workoutID = workoutID else { return }
            guard let workout = HealthKitManager.shared.getWorkout(forID: workoutID) else { return }
            
            if let shoe = shoesViewModel?.getDefaultShoe() {
                print("\(shoe.brand) - \(shoe.model)")
                shoe.workouts.append(workout.id)
                shoe.currentDistance += workout.totalDistance(unitPrefix: .kilo)
            }
        case "REMIND_ME_LATER":
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
