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
            ShoesListView(shoes: shoesViewModel.filteredShoes)
                .overlay {
                    if shoesViewModel.filteredShoes.isEmpty {
                        ContentUnavailableView.search
                    }
                }
        } else {
            ShoesView()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ShoesTab()
            .modelContainer(PreviewSampleData.container)
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager())
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
            .environment(SettingsManager.shared)
            .environment(HealthManager.shared)
    }
}
