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
    
    @ScaledMetric(relativeTo: .largeTitle) private var width: CGFloat = 140
    
    var body: some View {
        List {
            ForEach(shoesViewModel.filteredShoes) { shoe in
                ShoeListItem(shoe: shoe, width: width)
                    .background(Color.theme.containerBackground, in: RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous))
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
        .contentMargins(.horizontal, Constants.horizontalMargin, for: .scrollContent)
        .contentMargins(.top, 10, for: .scrollContent)
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
        .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.container.mainContext)))
        .environmentObject(StoreManager.shared)
        .environmentObject(NavigationRouter())
}
