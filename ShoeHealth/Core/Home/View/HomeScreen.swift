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
                    .navigationTitle("Workouts") 
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
                    ShoeFormView()
                case .setDefaultShoe(let runType):
                    ShoeSelectionView(
                        selectedShoe: shoesViewModel.getDefaultShoe(for: runType),
                        title: Prompts.SelectShoe.selectDefaultShoeTitle(for: runType),
                        description: Prompts.SelectShoe.selectDefaultShoeDescription(for: runType),
                        systemImage: "shoe.2",
                        onDone: { shoeID in
                            withAnimation {
                                shoesViewModel.setAsDefaultShoe(shoeID, for: [runType])
                            }
                    })
                case .addWorkoutToShoe(let workoutID):
                    ShoeSelectionView(
                        title: Prompts.SelectShoe.selectWorkoutShoeTitle,
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
                        Task {
                            for (workoutID, shoe) in selectionsDict {
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
        .alert("Limit reached", isPresented: $navigationRouter.showLimitAlert, actions: {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text("Cancel")
            }
            .foregroundStyle(.accent)

            Button {
                navigationRouter.showPaywall.toggle()
            } label: {
                Text("Upgrade")
            }
            .tint(.accent)
        }, message: {
            Text(shoesViewModel.getLimitReachedPrompt())
        })
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
        .environmentObject(StoreManager())
        .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}

#Preview("Empty") {
    HomeScreen()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environmentObject(NavigationRouter())
        .environmentObject(StoreManager())
        .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}
