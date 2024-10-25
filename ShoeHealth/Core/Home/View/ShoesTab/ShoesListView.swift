//
//  ShoesListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.04.2024.
//

import SwiftUI

struct ShoesListView: View {
    
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    private var shoes: [Shoe] = []
    
    @State private var selectedShoe: Shoe?
    
    init(shoes: [Shoe]) {
        self.shoes = shoes
    }
    
    var body: some View {
        List {
            ForEach(shoes) { shoe in
                ShoeListItem(shoe: shoe)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .disabled(isShoeRestricted(shoe.id))
                    .onTapGesture {
                        selectedShoe = shoe
                    }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(4)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .toolbarRole(.editor)
        .toolbar {
            toolbarItems
        }
        .navigationDestination(item: $selectedShoe) { shoe in
            ShoeDetailView(shoe: shoe, isShoeRestricted: isShoeRestricted(shoe.id))
        }
    }
}

// MARK: - View Components

extension ShoesListView {
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Sort Rule", selection: shoesViewModel.sortingRuleBinding) {
                    ForEach(SortingRule.allCases) { rule in
                        Text(rule.rawValue)
                            .tag(rule)
                    }
                }
                
                Divider()
                
                Button {
                    shoesViewModel.toggleSortOrder()
                } label: {
                    Label("Sort Order", systemImage: shoesViewModel.sortingOrder == .forward ? "chevron.up" : "chevron.down")
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .imageScale(.medium)
            }
        }
    }
}
// MARK: - Helper Methods

extension ShoesListView {
    
    private func isShoeRestricted(_ shoeID: UUID) -> Bool {
        return !storeManager.hasFullAccess && shoesViewModel.shouldRestrictShoe(shoeID)
    }
}

// MARK: - Preview

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoesListView(shoes: Shoe.previewShoes + Shoe.previewShoes)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .environmentObject(StoreManager())
                .navigationTitle("Shoes")
        }
    }
}
