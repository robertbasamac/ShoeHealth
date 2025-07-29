//
//  ShoeHealthApp.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import SwiftData
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "ShoeHealthApp")

@main
struct ShoeHealthApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
     
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var shoesViewModel: ShoesViewModel
    @State private var onboardingViewModel: OnboardingViewModel
    @State private var navigationRouter: NavigationRouter
    @State private var notificationManager: NotificationManager
    @State private var storeManager: StoreManager
    @State private var settingsManager: SettingsManager
    @State private var healthManager: HealthManager
        
    let container = ShoesStore.shared.modelContainer
    
    init () {
        let shoeHandler = ShoeHandler(modelContext: container.mainContext)
        let navigationRouter = NavigationRouter()
        let notificationManager = NotificationManager(shoeHandler: shoeHandler)
        let storeManager = StoreManager()
        let settingsManager = SettingsManager()
        let healthManager = HealthManager(settingsManager: settingsManager, notificationManager: notificationManager)
        
        self._navigationRouter = State(wrappedValue: navigationRouter)
        self._notificationManager = State(wrappedValue: notificationManager)
        self._storeManager = State(wrappedValue: storeManager)
        self._settingsManager = State(wrappedValue: settingsManager)
        self._healthManager = State(wrappedValue: healthManager)
        self._onboardingViewModel = State(wrappedValue: OnboardingViewModel(healthManager: healthManager, notificationManager: notificationManager))
        self._shoesViewModel = State(wrappedValue: ShoesViewModel(shoeHandler: shoeHandler, notificationManager: notificationManager, storeManager: storeManager, healthManager: healthManager, settingsManager: settingsManager))
        
        appDelegate.shoesViewModel = shoesViewModel
        appDelegate.navigationRouter = navigationRouter
        appDelegate.healthManager = healthManager
        appDelegate.settingsManager = settingsManager
        appDelegate.notificationManager = notificationManager
        appDelegate.storeManager = storeManager
        
        // override apple's buggy alerts tintColor
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.theme.accent)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(.dark)
                    .defaultAppStorage(UserDefaults(suiteName: System.AppGroups.shoeHealth)!)
                    .environmentObject(navigationRouter)
                    .environment(shoesViewModel)
                    .environment(onboardingViewModel)
                    .environment(notificationManager)
                    .environment(storeManager)
                    .environment(settingsManager)
                    .environment(healthManager)
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            Task {
                                await storeManager.updateCustomerProductStatus()
                            }
                        }
                    }
                
                ZStack {
                    if healthManager.isLoading || storeManager.isLoading {
                        LaunchView()
                            .transition(.opacity)
                    }
                }
                .zIndex(2.0)
            }
            .onChange(of: storeManager.hasFullAccess) { _, newValue in
                notificationManager.setActionableNotificationTypes(isPremiumUser: newValue)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .modelContainer(container)
    }
}
