//
//  ContentView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    @AppStorage("IS_ONBOARDING") var isOnboarding: Bool = true
    
    var body: some View {
        HomeScreen()
            .fullScreenCover(isPresented: $isOnboarding) {
                OnboardingScreen()
            }
    }
}

// MARK: - Previews

#Preview("Filled") {
    ContentView()
        .modelContainer(PreviewSampleData.container)
        .environmentObject(NavigationRouter())
        .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}

#Preview("Empty") {
    ContentView()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environmentObject(NavigationRouter())
        .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
        .environment(HealthManager.shared)
        .environment(SettingsManager.shared)
}
