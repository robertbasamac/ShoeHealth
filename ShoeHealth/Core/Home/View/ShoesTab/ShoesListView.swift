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
    
    @State private var showDeletionConfirmation: Bool = false
    @State private var shoeForDeletion: Shoe? = nil
    
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        swipeLeftActions(shoe: shoe)
                    }
                    .onTapGesture {
                        navigationRouter.navigate(to: .shoe(shoe))
                    }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(4)
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .contentMargins(.top, 10, for: .scrollContent)
        .contentMargins(.top, 10, for: .scrollIndicators)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .confirmationDialog(
            "Delete this shoe?",
            isPresented: $showDeletionConfirmation,
            titleVisibility: .visible,
            presenting: shoeForDeletion,
            actions: { shoe in
                confirmationActions(shoe: shoe)
            },
            message: { shoe in
                Text("Deleting \'\(shoe.brand) \(shoe.model) - \(shoe.nickname)\' shoe is permanent. This action cannot be undone.")
            })
        .safeAreaInset(edge: .bottom) {
            shoeCategoryPicker
        }
        .overlay {
            emptyShoesView
        }
        .toolbar {
            toolbarItems
        }
        .navigationDestination(for: Shoe.self) { shoe in
            ShoeDetailView(shoe: shoe)
        }
    }
}

// MARK: - View Components

extension ShoesListView {
    
    @ViewBuilder
    private func swipeLeftActions(shoe: Shoe) -> some View {
        Button {
            shoeForDeletion = shoe
            showDeletionConfirmation.toggle()
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
        
        Button(role: .destructive) {
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
    
    @ViewBuilder
    private func confirmationActions(shoe: Shoe) -> some View {
        Button("Cancel", role: .cancel) {
            shoeForDeletion = nil
        }
        
        Button("Delete", role: .destructive) {
            shoeForDeletion = nil
            
            withAnimation {
                shoesViewModel.deleteShoe(shoe.id)
            }
            
            if shoe.isDefaultShoe && !shoesViewModel.shoes.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigationRouter.showSheet = .setDefaultShoe
                }
            }
        }
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
    private var shoeCategoryPicker: some View {
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
