//
//  ShoeHealthApp.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import SwiftData

@main
struct ShoeHealthApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var storeManager: StoreManager
    @State private var shoesViewModel: ShoesViewModel
    @State private var healthManager = HealthManager.shared
    @State private var settingsManager = SettingsManager.shared
    
    init () {
        let storeManagerInstance = StoreManager()

        self._storeManager = StateObject(wrappedValue: storeManagerInstance)
        
        self._shoesViewModel = State(wrappedValue: ShoesViewModel(modelContext: ShoesStore.container.mainContext, storeManager: storeManagerInstance))
        
            // override apple's buggy alerts tintColor
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.theme.accent)
    }
    
    var body: some Scene {
        WindowGroup {
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
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        Task {
                            await storeManager.updateCustomerProductStatus()
                        }
                    }
                }
        }
        .modelContainer(ShoesStore.container)
    }
}
