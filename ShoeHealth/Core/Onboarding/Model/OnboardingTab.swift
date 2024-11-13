//
//  OnboardingTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 13.06.2024.
//

import Foundation

enum OnboardingTab: Int, CaseIterable {
    case welcome
    case healthKitAccess
    case notificationAccess
    
    var image: String {
        switch self {
        case .welcome:
            "ShoeHealth"
        case .healthKitAccess:
            "AppleHealth"
        case .notificationAccess:
            "bell.badge.fill"
        }
    }
    
    var title: String {
        switch self {
        case .welcome:
            "Welcome to Shoe Health"
        case .healthKitAccess:
            Prompts.HealthAccess.title
        case .notificationAccess:
            Prompts.Notifications.title
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            ""
        case .healthKitAccess:
            Prompts.HealthAccess.description
        case .notificationAccess:
            Prompts.Notifications.description
        }
    }
}
