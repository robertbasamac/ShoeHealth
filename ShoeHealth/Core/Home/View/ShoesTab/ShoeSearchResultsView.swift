//
//  ShoeSearchResultsView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.11.2024.
//

import SwiftUI

struct ShoeSearchResultsView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(StoreManager.self) private var storeManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @ScaledMetric(relativeTo: .largeTitle) private var width: CGFloat = 140
    
    var body: some View {
        List {
            ForEach(shoesViewModel.filteredShoes) { shoe in
                ShoeListItem(shoe: shoe, width: width)
                    .background(Color.theme.containerBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .disabled(shoesViewModel.shouldRestrictShoe(shoe.id))
                    .onTapGesture {
                        navigationRouter.navigate(to: .shoe(shoe))
                    }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(4)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .navigationDestination(for: Shoe.self) { shoe in
            ShoeDetailView(shoe: shoe)
        }
        .overlay {
            if shoesViewModel.filteredShoes.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ShoeSearchResultsView()
}
