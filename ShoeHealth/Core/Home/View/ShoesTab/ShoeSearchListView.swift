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

#Preview {
    NavigationStack {
        ShoesTab()
            .modelContainer(PreviewSampleData.container)
            .environmentObject(NavigationRouter())
    }
}
