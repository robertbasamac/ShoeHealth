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
    
    @State private var navigationRouter: NavigationRouter
    @State private var storeManager: StoreManager = StoreManager.shared
    @State private var shoesViewModel: ShoesViewModel
    @State private var healthManager = HealthManager.shared
    @State private var settingsManager = SettingsManager.shared
    
    let container = ShoesStore.shared.modelContainer
    
    init () {
        let shoeDataHandler = ShoeDataHandler(modelContext: container.mainContext)
        self._shoesViewModel = State(wrappedValue: ShoesViewModel(shoeDataHandler: shoeDataHandler))
        self._navigationRouter = State(wrappedValue: NavigationRouter())

        appDelegate.shoesViewModel = shoesViewModel
        appDelegate.navigationRouter = navigationRouter
        
        NotificationManager.shared.inject(shoeDataHandler: shoeDataHandler)
        
        logger.debug("initialized")
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
                    .environmentObject(storeManager)
                    .environment(shoesViewModel)
                    .environment(healthManager)
                    .environment(settingsManager)
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            Task {
                                await storeManager.updateCustomerProductStatus()
                            }
                        }
                    }
                
                ZStack {
                    if healthManager.isLoading {
                        LaunchView()
                            .transition(.opacity)
                    }
                }
                .zIndex(2.0)
            }
            .onChange(of: storeManager.hasFullAccess) { _, newValue in
                NotificationManager.shared.setActionableNotificationTypes(isPremiumUser: newValue)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .modelContainer(container)
    }
}
