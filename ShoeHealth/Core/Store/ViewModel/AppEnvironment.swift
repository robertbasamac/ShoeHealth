//
//  StoreManagingKey.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 02.07.2025.
//

import SwiftUI

struct AppEnvironmentKey: EnvironmentKey {
    
    static let defaultValue: AppEnvironment = AppEnvironment(
        storeManager: StoreManager(),
        settingsManager: SettingsManager(),
        healthManager: HealthManager(settingsManager: settingsManager)
//        navigationRouter: NavigationRouter()
    )
}

extension EnvironmentValues {
    
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}

struct AppEnvironment: Sendable {
    
    let storeManager: StoreManaging
    let settingsManager: SettingsManaging
    let healthManager: HealthManaging
//    let navigationRouter: NavigationRouting
}
