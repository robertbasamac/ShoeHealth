//
//  ShoeHealthApp.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct ShoeHealthApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var storeManager: StoreManager = StoreManager()
    @State private var shoesViewModel: ShoesViewModel
    @State private var healthManager = HealthManager.shared
    @State private var settingsManager = SettingsManager.shared
    
    let container = ShoesStore.shared.modelContainer
    
    init () {
        self._shoesViewModel = State(wrappedValue: ShoesViewModel(modelContext: container.mainContext))
        
        // override apple's buggy alerts tintColor
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.theme.accent)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(.dark)
                    .defaultAppStorage(UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")!)
                    .environmentObject(navigationRouter)
                    .environmentObject(storeManager)
                    .environment(shoesViewModel)
                    .environment(healthManager)
                    .environment(settingsManager)
                    .onAppear {
                        appDelegate.shoesViewModel = shoesViewModel
                        appDelegate.navigationRouter = navigationRouter
                        appDelegate.storeManager = storeManager
                    }
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
