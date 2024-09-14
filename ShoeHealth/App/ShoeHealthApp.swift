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
    
    @StateObject private var navigationRouter = NavigationRouter()
    @State private var shoesViewModel = ShoesViewModel(modelContext: ShoesStore.container.mainContext)
    @State private var healthManager = HealthManager.shared
    @State private var settingsManager = SettingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .defaultAppStorage(UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")!)
                .environmentObject(navigationRouter)
                .environment(shoesViewModel)
                .environment(healthManager)
                .environment(settingsManager)
                .onAppear {
                    appDelegate.shoesViewModel = shoesViewModel
                    appDelegate.navigationRouter = navigationRouter
                }
        }
        .modelContainer(ShoesStore.container)
    }
}
