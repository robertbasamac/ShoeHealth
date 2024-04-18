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
    
    @State private var showAddShoe: Bool = false
    @State private var selectedShoe: Shoe?
    
    @State private var showSheet: SheetType?
    
    @State private var selectedCategory: ShoeFilterType?
    
    enum SheetType: Identifiable {
        var id: Self { self }
        
        case addShoe
        case setDefaultShoe
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            
            ScrollView(.vertical) {
                VStack(spacing: 12) {
                    lastRunSection
                                        
                    if let shoe = shoesViewModel.getDefaultShoe() {
                        defaultShoeSection(shoe)
                    } else {
                        noDefaultShoeSection
                    }
                    
                    if !shoesViewModel.getRecentlyUsedShoes().isEmpty {
                        recentlyUsedSection
                    }
                    
                    if !shoesViewModel.getShoes(filter: .active).isEmpty {
                        activeShoesSection
                    }
                    
                    if !shoesViewModel.getShoes(filter: .retired).isEmpty {
                        retiredShoesSection
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Shoe Health")
//        .navigationBarTitleDisplayMode(.inline)
//        .scrollBounceBehavior(.basedOnSize)
//        .searchable(text: shoesViewModel.searchBinding, prompt: "Search Shoes")
//        .searchScopes(shoesViewModel.filterTypeBinding) {
//            ForEach(ShoeFilterType.allCases) { filterType in
//                Text(filterType.rawValue)
//                    .tag(filterType)
//            }
//        }
//        .overlay {
//            emptyShoesView
//        }
        .toolbar {
            toolbarItems
        }
//        .navigationDestination(item: $selectedShoe) { shoe in
//            ShoeDetailCarouselView(shoes: shoesViewModel.filteredShoes, selectedShoeID: shoe.id)
//                .navigationTitle(getNavigationBarTitle())
//        }
        .navigationDestination(item: $selectedCategory) { category in
            ShoesListView(shoes: shoesViewModel.getShoes(filter: category))
                .navigationTitle(category == .active ? "Active Shoes" : "Retired Shoes")
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
            .interactiveDismissDisabled(sheetType == .setDefaultShoe)
        }
    }
}

// MARK: - View Components

extension ShoesTab {
    
    @ViewBuilder
    private var lastRunSection: some View {
        VStack(spacing: 0) {
            Text("Last Run")
                .asHeader()
            
            VStack {
                Text("Last Run")
                    .frame(height: 200)
            }
            .frame(maxWidth: .infinity)
            .contentRoundedBackground()
        }
        
    }
    
    @ViewBuilder
    private func defaultShoeSection(_ shoe: Shoe) -> some View {
        VStack(spacing: 0) {
            Text("Default Shoe")
                .asHeader()
            
            ShoeListItem(shoe: shoe, width: 140)
                .contentRoundedBackground()
        }
    }
    
    @ViewBuilder
    private var noDefaultShoeSection: some View {
        VStack(spacing: 0) {
            Text("Default Shoe")
                .asHeader()
            
            HStack(spacing: 0) {
                ShoeImage(width: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack {
                    Text("No Default Shoe")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        showSheet = .setDefaultShoe
                    } label: {
                        Text("Select Shoe")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.black)
                    }
                    .tint(.accentColor)
                    .buttonStyle(BorderedProminentButtonStyle())
                    .buttonBorderShape(.capsule)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 12)
            }
            .contentRoundedBackground()
        }
    }
    
    @ViewBuilder
    private var recentlyUsedSection: some View {
        VStack(spacing: 0) {
            Text("Recently Used")
                .asHeader()
            
            shoesCarousel(shoes: shoesViewModel.getRecentlyUsedShoes())
        }
    }
    
    @ViewBuilder
    private var activeShoesSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Active Shoes")
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .asHeader()
            .onTapGesture {
                selectedCategory = .active
            }
            
            shoesCarousel(shoes: shoesViewModel.getShoes(filter: .active))
        }
    }
    
    @ViewBuilder
    private var retiredShoesSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Retired Shoes")
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .asHeader()
            .onTapGesture {
                selectedCategory = .retired
            }
            
            shoesCarousel(shoes: shoesViewModel.getShoes(filter: .retired))
        }
    }
    
    @ViewBuilder
    private func shoesCarousel(shoes: [Shoe]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(shoes) { shoe in
                    ShoeCell(shoe: shoe, width: 140, displayProgress: true)
                        .contextMenu {
                            Button(role: .destructive) {
                                shoesViewModel.deleteShoe(shoe.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
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
                        } preview: {
                            ShoeCell(shoe: shoe, width: 300)
                                .padding(10)
                        }
                        .onTapGesture {
                            selectedShoe = shoe
                        }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
    }
    
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
    private var emptyShoesView: some View {
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
        } else {
            if shoesViewModel.searchFilteredShoes.isEmpty {
                if !shoesViewModel.searchText.isEmpty {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView {
                        Label("No \(shoesViewModel.filterType.rawValue) in your collection.", systemImage: "shoe.circle")
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
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                showSheet = .addShoe
            } label: {
                Image(systemName: "plus")
            }
        }
        
//        ToolbarItem(placement: .topBarLeading) {
//            Menu {
//                Picker("Filtering", selection: shoesViewModel.filterTypeBinding) {
//                    ForEach(ShoeFilterType.allCases) { filterType in
//                        Text(filterType.rawValue)
//                            .tag(filterType)
//                    }
//                }
//                
//                Divider()
//                
//                Picker("Sorting", selection: shoesViewModel.sortTypeBinding) {
//                    ForEach(ShoeSortType.allCases) { sortType in
//                        Text(sortType.rawValue)
//                            .tag(sortType)
//                    }
//                }
//                
//                Divider()
//                
//                Button {
//                    shoesViewModel.toggleSortOrder()
//                } label: {
//                    Label("Sort Order", systemImage: shoesViewModel.sortOrder == .forward ? "chevron.down" : "chevron.up")
//                }
//            } label: {
//                Image(systemName: "line.3.horizontal.decrease.circle.fill")
//                    .foregroundStyle(getFilteringImageColors().0, getFilteringImageColors().1)
//            }
//        }
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
        return selectedCategory?.rawValue ?? "Shoes"
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

fileprivate extension View {
    
    func asHeader() -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal], 20)
            .padding(.top, 8)
            .contentShape(.rect)
    }
    
    func contentRoundedBackground() -> some View {
        self
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
            .padding(.top, 8)
    }
}
