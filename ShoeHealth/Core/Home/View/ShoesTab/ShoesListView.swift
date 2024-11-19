//
//  ShoesListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.04.2024.
//

import SwiftUI

struct ShoesListView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @State private var category: ShoeCategory = .all
    
    init(forCategory category: ShoeCategory = .all) {
        self._category = State(wrappedValue: category)
    }
    
    var body: some View {
        List {
            ForEach(shoesViewModel.getShoes(for: category)) { shoe in
                ShoeListItem(shoe: shoe)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .disabled(isShoeRestricted(shoe.id))
                    .onTapGesture {
                        navigationRouter.navigate(to: .shoe(shoe))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        swipeLeftActions(shoe: shoe)
                    }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(4)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.top, 10, for: .scrollContent)
        .contentMargins(.top, 10, for: .scrollIndicators)
//        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .safeAreaInset(edge: .bottom) {
            Picker("Category", selection: $category) {
                ForEach(ShoeCategory.allCases) { category in
                    Text(category.rawValue)
                        .tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 1)
            .background(.bar, in: .rect(cornerRadius: 8))
            .padding(.bottom, 10)
            .padding(.horizontal, 40)
        }
        .overlay {
            emptyShoesView
        }
        .toolbar {
            toolbarItems
        }
        .navigationDestination(for: Shoe.self) { shoe in
            ShoeDetailView(shoe: shoe, isShoeRestricted: isShoeRestricted(shoe.id))
        }
    }
}

// MARK: - View Components

extension ShoesListView {
    
    @ViewBuilder
    private func swipeLeftActions(shoe: Shoe) -> some View {
        Button(role: .destructive) {
            withAnimation {
                shoesViewModel.deleteShoe(shoe.id)
            }
            
            if shoe.isDefaultShoe && !shoesViewModel.shoes.isEmpty {
                navigationRouter.showSheet = .setDefaultShoe
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
        
        Button {
            let setNewDefaultShoe = shoe.isDefaultShoe && !shoe.isRetired
            
            withAnimation {
                shoesViewModel.retireShoe(shoe.id)
            }
            
            if setNewDefaultShoe {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigationRouter.showSheet = .setDefaultShoe
                }
            }
        } label: {
            if shoe.isRetired {
                Label("Reinstate", systemImage: "bolt.fill")
            } else {
                Label("Retire", systemImage: "bolt.slash.fill")
            }
        }
        .tint(shoe.isRetired ? .green : .red)
    }
    
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
            .disabled(shoesViewModel.getShoes(for: category).isEmpty)
        }
    }
    
    @ViewBuilder
    private var emptyShoesView: some View {
        if shoesViewModel.getShoes(for: category).isEmpty {
            ContentUnavailableView {
                Label("No \(category.title)", systemImage: "shoe.circle")
            } description: {
                    Text("There are currently no \(category.title) available in your collection.")
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
            ShoesListView(forCategory: .all)
                .environmentObject(NavigationRouter())
                .environmentObject(StoreManager())
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .navigationTitle("Shoes")
        }
    }
}
