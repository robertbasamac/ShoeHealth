//
//  ShoeSearchResultsView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.11.2024.
//

import SwiftUI

struct ShoeSearchResultsView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
       
    var body: some View {
        List {
            ForEach(shoesViewModel.filteredShoes) { shoe in
                ShoeListItem(shoe: shoe)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .disabled(isShoeRestricted(shoe.id))
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
    
// MARK: - Helper Methods

extension ShoeSearchResultsView {
    
    private func isShoeRestricted(_ shoeID: UUID) -> Bool {
        return !storeManager.hasFullAccess && shoesViewModel.shouldRestrictShoe(shoeID)
    }
}


// MARK: - Previews

#Preview {
    ShoeSearchResultsView()
}
