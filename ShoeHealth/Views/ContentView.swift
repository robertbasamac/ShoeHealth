//
//  ContentView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    
    var body: some View {
        TabView(selection: $navigationRouter.selectedTab) {
            NavigationStack {
                ShoesTab()
            }
            .tabItem {
                Label(Tab.shoes.rawValue, systemImage: Tab.shoes.systemImageName)
            }
            .tag(Tab.shoes)
            
            NavigationStack {
                WorkoutsTab()
                    .navigationTitle("Workouts")
            }
            .tabItem {
                Label(Tab.workouts.rawValue, systemImage: Tab.workouts.systemImageName)
            }
            .tag(Tab.workouts)
        }
        .sheet(item: $navigationRouter.workout) { workout in
            NavigationStack {
                ShoeSelectionView(workout: workout)
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Previews

#Preview("Filled") {
    ContentView()
        .modelContainer(PreviewSampleData.container)
        .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        .environmentObject(NavigationRouter())
}

#Preview("Empty") {
    ContentView()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
        .environmentObject(NavigationRouter())
}
