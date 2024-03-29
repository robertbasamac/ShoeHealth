//
//  ShoesTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import SwiftData

struct ShoesTab: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    
    @State private var showAddShoe: Bool = false
    @State private var selectedShoe: Shoe?
    
    @State private var showSetDefaultShoe: Bool = false
    
    @State private var showSheet: SheetType?
    
    enum SheetType: Identifiable {
        var id: Self { self }
        
        case addShoe
        case setDefaultShoe
    }
    
    var body: some View {
        List {
            ForEach(shoesViewModel.searchFilteredShoes) { shoe in
                ShoeListItem(shoe: shoe)
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .onTapGesture {
                        selectedShoe = shoe
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        swipeRightActions(shoe: shoe)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        swipeLeftActions(shoe: shoe)
                    }
            }
            .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(getNavigationBarTitle())
        .searchable(text: shoesViewModel.searchBinding, prompt: "Search Shoes")
        .searchScopes(shoesViewModel.filterTypeBinding) {
            ForEach(ShoeFilterType.allCases) { filterType in
                Text(filterType.rawValue)
                    .tag(filterType)
            }
        }
        .scrollBounceBehavior(shoesViewModel.shoes.isEmpty ? .basedOnSize : .automatic)
        .overlay {
            emptyShoesView()
        }
        .toolbar {
            toolbarItems()
        }
        .navigationDestination(item: $selectedShoe) { shoe in
            ShoeDetailCarouselView(shoes: shoesViewModel.filteredShoes, selectedShoeID: shoe.id)
                .navigationTitle(getNavigationBarTitle())
        }
        .sheet(item: $showSheet) { sheetType in
            NavigationStack {
                switch sheetType {
                case .addShoe:
                    AddShoeView()
                case .setDefaultShoe:
                    ShoeSelectionView {
                        Text("Select your new Default Shoe")
                    } onDone: { shoeID in
                        shoesViewModel.setAsDefaultShoe(shoeID)
                    }
                    .navigationTitle("Set Default Shoe")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(sheetType == .addShoe ? .visible : .hidden)
            .presentationCompactAdaptation(sheetType == .addShoe ? .sheet : .fullScreenCover)
        }
    }
}

// MARK: - View Components

extension ShoesTab {
    
    @ViewBuilder
    private func swipeRightActions(shoe: Shoe) -> some View {
        Button {
            shoesViewModel.retireShoe(shoe.id)
            
            if shoe.isRetired && shoe.isDefaultShoe {
                showSheet = .setDefaultShoe
            }
        } label: {
            if shoe.isRetired {
                Label("Reinstate", systemImage: "bolt.fill")
            } else {
                Label("Retire", systemImage: "bolt.slash.fill")
            }
        }
        .tint(shoe.isRetired ? .green : .red)
        
        if !shoe.isDefaultShoe {
            Button {
                shoesViewModel.setAsDefaultShoe(shoe.id)
            } label: {
                Label("Set Default", systemImage: "shoe.2")
            }
            .tint(Color.gray)
        }
    }
    
    @ViewBuilder
    private func swipeLeftActions(shoe: Shoe) -> some View {
        Button(role: .destructive) {
            withAnimation {
                shoesViewModel.deleteShoe(shoe.id)
            }
            
            if shoe.isDefaultShoe && !shoesViewModel.shoes.isEmpty {
                showSheet = .setDefaultShoe
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder
    private func emptyShoesView() -> some View {
        if shoesViewModel.shoes.isEmpty {
            ContentUnavailableView {
                Label("No Shoes in your collection.", systemImage: "shoe.circle")
            } description: {
                Text("New shoes you add will appear here.\nTap the button below to add a new shoe.")
            } actions: {
                Button {
                    showSheet = .addShoe
                } label: {
                    Text("Add Shoe")
                        .padding(4)
                        .foregroundStyle(.black)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                showSheet = .addShoe
            } label: {
                Image(systemName: "plus")
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Filtering", selection: shoesViewModel.filterTypeBinding) {
                    ForEach(ShoeFilterType.allCases) { filterType in
                        Text(filterType.rawValue)
                            .tag(filterType)
                    }
                }
                
                Divider()
                
                Picker("Sorting", selection: shoesViewModel.sortTypeBinding) {
                    ForEach(ShoeSortType.allCases) { sortType in
                        Text(sortType.rawValue)
                            .tag(sortType)
                    }
                }
                
                Divider()
                
                Button {
                    shoesViewModel.toggleSortOrder()
                } label: {
                    Label("Sort Order", systemImage: shoesViewModel.sortOrder == .forward ? "chevron.down" : "chevron.up")
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .foregroundStyle(getFilteringImageColors().0, getFilteringImageColors().1)
            }
        }
    }
}

// MARK: - Helper Methods

extension ShoesTab {
    
    private func getFilteringImageColors() -> (Color, Color) {
        switch shoesViewModel.filterType {
        case .all:
            return (Color.accentColor, Color(uiColor: .secondarySystemGroupedBackground))
        case .active:
            return (Color(uiColor: .secondarySystemGroupedBackground), Color.accentColor)
        case .retired:
            return (Color(uiColor: .secondarySystemGroupedBackground), Color.red)
        }
    }
    
    private func getNavigationBarTitle() -> String {
        return shoesViewModel.filterType.rawValue
    }
}

// MARK: - Preview

#Preview("Filled") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.container)
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
    }
}

#Preview("Empty") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.emptyContainer)
            .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
    }
}
