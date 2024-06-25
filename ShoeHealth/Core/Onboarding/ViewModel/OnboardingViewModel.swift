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
final class OnboardingViewModel: @unchecked Sendable {
    
    var isHealthAuthorized: Bool = false
    var isNotificationsAuthorized: Bool = false
    
    var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let healthManager = HealthManager.shared
    private let notificationManager = NotificationManager.shared
    
    func requestHealthAuthorization() async {        
        let authorization = await healthManager.requestHealthAuthorization()
        
        await MainActor.run {
            isHealthAuthorized = authorization
        }
    }
    
    func requestNotificationAuthorization() async {
        switch notificationAuthorizationStatus {
        case .notDetermined:
            logger.debug("Requesting notification access..., \(Thread.current)")
                        
            let authorization = await notificationManager.requestNotificationAuthorization()
            let authorizationStatus = await notificationManager.getNotificationAuthorizationStatus()
            
            await MainActor.run {
                isNotificationsAuthorized = authorization
                notificationAuthorizationStatus = authorizationStatus
            }
        case .denied:
            logger.debug("Opening settings...")
            
            await openSettings()
        case .authorized, .provisional, .ephemeral:
            logger.debug("Permission already granted.")
        @unknown default:
            logger.warning("Unknown status.")
        }
    }
    
    func checkNotificationAuthorizationStatus() async {
        let authorizationStatus = await notificationManager.getNotificationAuthorizationStatus()
        
        await MainActor.run {
            notificationAuthorizationStatus = authorizationStatus
            
            if notificationAuthorizationStatus == .authorized {
                isNotificationsAuthorized = true
            } else {
                isNotificationsAuthorized = false
            }
        }
    }
    
    @MainActor
    private func openSettings() {
        if let appNotificationsSettingsURL = URL(string: UIApplication.openNotificationSettingsURLString), UIApplication.shared.canOpenURL(appNotificationsSettingsURL) {
            UIApplication.shared.open(appNotificationsSettingsURL)
        }
    }
}
