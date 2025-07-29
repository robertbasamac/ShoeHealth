//
//  HomeScreen.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.06.2024.
//

import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView(selection: $navigationRouter.selectedTab) {
            NavigationStack(path: $navigationRouter.workoutsNavigationPath) {
                WorkoutsTab()
            }
            .tabItem {
                Label(TabItem.workouts.rawValue, systemImage: TabItem.workouts.systemImageName)
            }
            .tag(TabItem.workouts)
            
            NavigationStack(path: $navigationRouter.shoesNavigationPath) {
                ShoesTab()
            }
            .tabItem {
                Label(TabItem.shoes.rawValue, systemImage: TabItem.shoes.systemImageName)
            }
            .tag(TabItem.shoes)
            
            NavigationStack {
                SettingsTab()
            }
            .tabItem {
                Label(TabItem.settings.rawValue, systemImage: TabItem.settings.systemImageName)
            }
            .tag(TabItem.settings)
        }
        .task {
            await healthManager.fetchRunningWorkouts()
        }
    }
}

// MARK: - Previews

#Preview("Filled") {
    HomeScreen()
        .modelContainer(PreviewSampleData.container)
        .environmentObject(NavigationRouter())
}

#Preview("Empty") {
    HomeScreen()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environmentObject(NavigationRouter())
}
