//
//  ShoeSearchListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 24.10.2024.
//

import SwiftUI

struct ShoeSearchListView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.isSearching) var isSearching
    
    var body: some View {
        if isSearching && !shoesViewModel.searchText.isEmpty {
            ShoeSearchResultsView()
        } else {
            ShoesView()
        }
    }
}

// MARK: - Preview

#Preview("Filled") {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
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
}

#Preview("Empty") {
    ModelContainerPreview(PreviewSampleData.emptyInMemoryContainer) {
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
}
