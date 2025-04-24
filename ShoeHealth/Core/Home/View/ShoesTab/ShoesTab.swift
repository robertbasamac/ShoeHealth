//
//  ShoesTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import SwiftData
import HealthKit

struct ShoesTab: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    
    @State private var selectedShoe: Shoe?
    @State private var selectedCategory: ShoeCategory?
    
    var body: some View {
        ShoeSearchListView()
            .navigationTitle("Shoe Health")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .searchable(
                text: shoesViewModel.searchBinding,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search Shoes"
            )
    }
}

// MARK: - Preview

#Preview("Filled") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.container)
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager.shared)
            .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.container.mainContext)))
            .environment(SettingsManager.shared)
            .environment(HealthManager.shared)
    }
}

#Preview("Empty") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.emptyContainer)
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager.shared)
            .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.emptyContainer.mainContext)))
            .environment(SettingsManager.shared)
            .environment(HealthManager.shared)
    }
}
