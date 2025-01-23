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
    @EnvironmentObject private var storeManager: StoreManager

    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @Environment(\.dismiss) private var dismiss

    @AppStorage("IS_ONBOARDING") var isOnboarding: Bool = true
    
    var body: some View {
        HomeScreen()
            .fullScreenCover(isPresented: $isOnboarding) {
                OnboardingScreen()
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
            .alert(navigationRouter.featureAlert?.title ?? "", isPresented: $navigationRouter.showFeatureRestrictedAlert, actions: {
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
                Text(navigationRouter.featureAlert?.message ?? "")
            })
            .onOpenURL { url in
                handleIncomingURL(url)
            }
    }
}

// MARK: - Helper Methods

extension ContentView {
    
    private func handleIncomingURL(_ url: URL) {
        print("handleIncomingURL: \(url)")
        
        guard url.scheme == "shoeHealthApp" else { return }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        if let action = components.host, action == "show-paywall", !navigationRouter.showPaywall {
            navigationRouter.showPaywall.toggle()
            return
        }
        
        if let action = components.host, action == "show-addShoe", navigationRouter.showSheet != .addShoe {
                navigationRouter.showSheet = .addShoe
            return
        }
        
        if let action = components.host, action == "show-selectShoe",
           let runTypeName = components.queryItems?.first(where: { $0.name == "runType" })?.value {
            let runType = RunType.create(from: runTypeName)
            
            if navigationRouter.showSheet != .setDefaultShoe(forRunType: runType) {
                navigationRouter.showSheet = .setDefaultShoe(forRunType: runType)
                return
            }
        }
        
        if let matchShoe = shoesViewModel.shoes.first(where: { $0.url == url }),
           navigationRouter.showShoeDetails != matchShoe,
           navigationRouter.showSheet == nil,
           navigationRouter.showPaywall == false,
           !navigationRouter.isShoeInCurrentStack(matchShoe.id) {
            navigationRouter.showShoeDetails = matchShoe
            return
        }
    }
}

// MARK: - Previews

#Preview("Filled") {
    ContentView()
        .modelContainer(PreviewSampleData.container)
        .environmentObject(NavigationRouter())
        .environmentObject(StoreManager())
        .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}

#Preview("Empty") {
    ContentView()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environmentObject(NavigationRouter())
        .environmentObject(StoreManager())
        .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}
