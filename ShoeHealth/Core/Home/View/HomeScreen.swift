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
            
            NavigationStack(path: $navigationRouter.shoesTabPath) {
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
        .sheet(item: $navigationRouter.showSheet) { sheetType in
            NavigationStack {
                switch sheetType {
                case .addShoe:
                    AddShoeView()
                case .setDefaultShoe:
                    ShoeSelectionView(title: Prompts.SelectShoe.selectDefaultShoeTitle,
                                      description: Prompts.SelectShoe.selectDefaultShoeDescription,
                                      systemImage: "shoe.2",
                                      onDone: { shoeID in
                        shoesViewModel.setAsDefaultShoe(shoeID)
                    })
                case .addToShoe(let workoutID):
                    ShoeSelectionView(title: Prompts.SelectShoe.assignWorkoutsTitle,
                                      description: Prompts.SelectShoe.assignWorkoutsDescription,
                                      systemImage: "shoe.2",
                                      onDone: { shoeID in
                        shoesViewModel.add(workoutIDs: [workoutID], toShoe: shoeID)
                    })
                }
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(sheetType == .addShoe ? .visible : .hidden)
            .interactiveDismissDisabled(sheetType == .setDefaultShoe)
        }
    }
}

// MARK: - Previews

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
