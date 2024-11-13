//
//  OnboardingViewModel.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 15.06.2024.
//

import Foundation
import NotificationCenter
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "OnboardingViewModel")

@Observable
class OnboardingViewModel {
    
    var isHealthAuthorized = false
    var isNotificationsAuthorized = false
        
    private let healthManager = HealthManager.shared
    private let notificationManager = NotificationManager.shared
    
    func requestHealthAuthorization() async {
        let authorization = await healthManager.requestHealthAuthorization()
        
        await MainActor.run {
            isHealthAuthorized = authorization
        }
    }
    
    func requestNotificationAuthorization() async {
        switch notificationManager.notificationAuthorizationStatus {
        case .notDetermined:
            logger.debug("Requesting notification access...")
            
            let authorization = await notificationManager.requestNotificationAuthorization()
            
            await MainActor.run {
                isNotificationsAuthorized = authorization
            }
        case .denied:
            logger.debug("Opening settings...")
            
            await notificationManager.openSettings()
        case .authorized, .provisional, .ephemeral:
            logger.debug("Permission already granted.")
        @unknown default:
            logger.warning("Unknown status.")
        }
    }
    
    func checkNotificationAuthorizationStatus() async {
        await notificationManager.retrieveNotificationAuthorizationStatus()
    }
}
