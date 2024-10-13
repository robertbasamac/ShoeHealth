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
                case .addWorkoutToShoe(let workoutID):
                    ShoeSelectionView(title: Prompts.SelectShoe.selectWorkoutShoeTitle,
                                      description: Prompts.SelectShoe.selectWorkoutShoeDescription,
                                      systemImage: "figure.run.circle",
                                      onDone: { shoeID in
                        Task {
                            await shoesViewModel.add(workoutIDs: [workoutID], toShoe: shoeID)
                        }
                    })
                case .addMultipleWorkoutsToShoe(workoutIDs: let workoutIDs):
                    MultipleShoeSelectionView(workoutIDs: workoutIDs,
                                              title: Prompts.SelectShoe.selectMultipleWorkoutShoeTitle,
                                              description: Prompts.SelectShoe.selectMultipleWorkoutShoeDescription,
                                              systemImage: "figure.run.circle",
                                              onDone: { selectionsDict in
                        for (workoutID, shoe) in selectionsDict {
                            Task {
                                await shoesViewModel.add(workoutIDs: [workoutID], toShoe: shoe.id)
                            }
                        }
                    })
                }
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(
                {
                    switch sheetType {
                    case .addShoe:
                        return .visible
                    default:
                        return .hidden
                    }
                }()
            )
            .interactiveDismissDisabled(
                {
                    switch sheetType {
                    case .setDefaultShoe, .addMultipleWorkoutsToShoe:
                        return true
                    default:
                        return false
                    }
                }()
            )
        }
        .fullScreenCover(item: $navigationRouter.showShoeDetails) { shoe in
            NavigationStack {
                ShoeDetailView(shoe: shoe, backButtonSymbol: "xmark")
            }
        }
        .fullScreenCover(isPresented: $navigationRouter.showPaywall) {
            NavigationStack {
                PaywallView()
            }
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
        .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}

#Preview("Empty") {
    HomeScreen()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environmentObject(NavigationRouter())
        .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}
