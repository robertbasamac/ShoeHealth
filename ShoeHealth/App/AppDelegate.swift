//
//  AppDelegate.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.12.2023.
//

import Foundation
import UIKit
import HealthKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("App Delegate - didFinishLaunchingWithOptions")
        
        let healthManager = HealthKitManager.shared
        healthManager.requestHealthAuthorization()
        
        let notificationManager = NotificationManager.shared
        notificationManager.requestAuthorization()
        
        return true
    }
}
