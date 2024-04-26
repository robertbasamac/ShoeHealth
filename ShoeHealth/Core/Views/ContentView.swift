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
    @Environment(ShoesViewModel.self) private var shoesViewModel: ShoesViewModel
    
    var body: some View {
        TabView(selection: $navigationRouter.selectedTab) {
            NavigationStack {
                WorkoutsTab()
                    .navigationTitle("Workouts")
            }
            .tabItem {
                Label(TabItem.workouts.rawValue, systemImage: TabItem.workouts.systemImageName)
            }
            .tag(TabItem.workouts)
            
            NavigationStack {
                ShoesTab()
            }
            .tabItem {
                Label(TabItem.shoes.rawValue, systemImage: TabItem.shoes.systemImageName)
            }
            .tag(TabItem.shoes)
            
            NavigationStack {
                SettingsTab()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label(TabItem.settings.rawValue, systemImage: TabItem.settings.systemImageName)
            }
            .tag(TabItem.settings)
        }
        .sheet(item: $navigationRouter.workout) { workout in
            NavigationStack {
                ShoeSelectionView {
                    Text("Select a Shoe to assign the newly recorded Workout")
                } onDone: { shoeID in
                    shoesViewModel.add(workoutIDs: [workout.id], toShoe: shoeID)
                }
                .navigationTitle("Assign Workout")
                .navigationBarTitleDisplayMode(.inline)
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
