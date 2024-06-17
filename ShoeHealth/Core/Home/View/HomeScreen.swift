//
//  HomeScreen.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.06.2024.
//

import SwiftUI

struct HomeScreen: View {
    
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
                ShoeSelectionView(title: Prompts.SelectShoe.selectWorkoutShoeTitle,
                                  description: Prompts.SelectShoe.selectWorkoutShoeDescription,
                                  systemImage: "shoe.2",
                                  onDone: { shoeID in
                    shoesViewModel.add(workoutIDs: [workout.id], toShoe: shoeID)
                })
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview("Filled") {
    HomeScreen()
        .modelContainer(PreviewSampleData.container)
        .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        .environmentObject(NavigationRouter())
}

#Preview("Empty") {
    HomeScreen()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
        .environmentObject(NavigationRouter())
}
