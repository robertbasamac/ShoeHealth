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
        .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        .environmentObject(NavigationRouter())
}

#Preview("Empty") {
    ContentView()
        .modelContainer(PreviewSampleData.emptyContainer)
        .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
        .environmentObject(NavigationRouter())
}
