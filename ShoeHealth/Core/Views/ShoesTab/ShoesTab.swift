//
//  ShoesTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import SwiftData
import HealthKit

struct ShoesTab: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @State private var selectedShoe: Shoe?
    @State private var showSheet: SheetType?
    @State private var selectedCategory: ShoeFilterType?
    
    @State private var headerOpacity: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            header
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(2)
            
            ScrollView(.vertical) {
                VStack(spacing: 12) {
                    lastRunSection(run: HealthKitManager.shared.getLastRun())
                    
                    defaultShoeSection(shoesViewModel.getDefaultShoe())
                    
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
                .readingFrame { frame in
                    let topPadding = UIApplication.topSafeAreaInsets + 44
                    
                    headerOpacity = interpolateOpacity(position: frame.minY, minPosition: topPadding - 2, maxPosition: topPadding, reversed: true)
                }
            }
            .contentMargins(.top, 44)
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedShoe) { shoe in
            ShoeDetailView(shoe: shoe)
        }
        .navigationDestination(item: $selectedCategory) { category in
            ShoesListView(shoes: shoesViewModel.getShoes(filter: category))
                .navigationTitle(category == .active ? "Active Shoes" : "Retired Shoes")
        }
        .sheet(item: $showSheet) { sheetType in
            NavigationStack {
                switch sheetType {
                case .addShoe:
                    NavigationStack {
                        AddShoeView()
                    }
                case .setDefaultShoe:
                    NavigationStack {
                        ShoeSelectionView {
                            Text("Select your new Default Shoe")
                        } onDone: { shoeID in
                            shoesViewModel.setAsDefaultShoe(shoeID)
                        }
                    }
                    .navigationTitle("Set Default Shoe")
                    .navigationBarTitleDisplayMode(.inline)
                case .addToShoe(let workoutID):
                    NavigationStack {
                        ShoeSelectionView {
                            Text("Select a Shoe to assign the newly recorded Workout")
                        } onDone: { shoeID in
                            shoesViewModel.add(workoutIDs: [workoutID], toShoe: shoeID)
                        }
                        .navigationTitle("Assign Workout")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.visible)
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
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                showSheet = .addShoe
            } label: {
                Image(systemName: "plus")
                    .asHeaderImageButton()
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(.bar.opacity(headerOpacity))
        .overlay(alignment: .bottom, content: {
            Divider()
                .opacity(headerOpacity)
        })
        .overlay {
            Text("Shoe Health")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private func lastRunSection(run: HKWorkout?) -> some View {
        VStack(spacing: 0) {
            Text("Last Run")
                .asHeader()
            
            Group {
                if let lastRun = run {
                    VStack(spacing: 8) {
                        HStack {
                            runDateAndTimeSection(lastRun)
                            runUsedShoeSection(lastRun)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        Divider()

                        runStatsSection(lastRun)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 10)
                }
                else {
                    Text("Your latest run will appear here.")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .roundedContainer()
        }
    }
    
    @ViewBuilder
    private func defaultShoeSection(_ shoe: Shoe?) -> some View {
        if let shoe = shoe {
            VStack(spacing: 0) {
                Text("Default Shoe")
                    .asHeader()
                
                ShoeListItem(shoe: shoe, width: 140)
                    .roundedContainer()
                    .onTapGesture {
                        selectedShoe = shoe
                    }
            }
        } else {
            VStack(spacing: 0) {
                Text("Default Shoe")
                    .asHeader()
                
                HStack(spacing: 0) {
                    ShoeImage()
                        .frame(width: 140, height: 140)
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
                .roundedContainer()
            }
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
                                withAnimation {
                                    shoesViewModel.deleteShoe(shoe.id)
                                }
                                
                                if shoe.isDefaultShoe && !shoesViewModel.shoes.isEmpty {
                                    showSheet = .setDefaultShoe
                                }
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
                            
                            if !shoe.isDefaultShoe {
                                Button {
                                    shoesViewModel.setAsDefaultShoe(shoe.id)
                                } label: {
                                    Label("Set Default", systemImage: "shoe.2")
                                }
                            }
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
    private func runDateAndTimeSection(_ run: HKWorkout) -> some View {
        VStack(alignment: .leading) {
            Text(run.startDateAsString)
            Text("\(run.startTimeAsString) - \(run.endTimeAsString)")
                .foregroundStyle(.secondary)
                .textScale(.secondary)
        }
        .font(.system(size: 17, weight: .regular))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func runStatsSection(_ run: HKWorkout) -> some View {
        VStack(spacing: 8) {
            HStack {
                StatCell(title: "Duration", value: run.durationAsString, color: .yellow)
                StatCell(title: "Distance", value: String(format: "%.2f", run.totalDistance(unitPrefix: .kilo)), unit: UnitLength.kilometers.symbol, color: .blue)
            }
            
            Divider()
            
            HStack {
                StatCell(title: "Avg Power", value: String(format: "%0.0f", run.averagePower), unit: UnitPower.watts.symbol, color: .accentColor)
                StatCell(title: "Avg Cadence", value: String(format: "%.0f", run.averageCadence), unit: "SPM", color: .cyan)
            }
            
            Divider()
            
            HStack {
                StatCell(title: "Avg Pace", value: String(format: "%d'%02d\"", run.averagePace.minutes, run.averagePace.seconds), unit: "/KM", color: .teal)
                StatCell(title: "Avg Heart Rate", value: String(format: "%.0f", run.averageHeartRate), unit: "BPM", color: .red)
            }
        }
    }
    
    @ViewBuilder
    private func runUsedShoeSection(_ run: HKWorkout) -> some View {
        Group {
            if let shoe = shoesViewModel.getShoe(ofWorkoutID: run.id) {
                VStack(alignment: .leading) {
                    Text("\(shoe.brand)")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    
                    Text("\(shoe.model)")
                        .font(.system(size: 18))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
                .onTapGesture {
                    selectedShoe = shoe
                }
            } else {
                Text("No shoe selected for this workout.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.center)
                    .contentShape(.rect)
                    .onTapGesture {
                        showSheet = .addToShoe(workoutID: run.id)
                    }
            }
        }
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) {
            Image(systemName: "shoe.2.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .offset(x: -50)
        }
        .overlay(alignment: .trailing) {
            Image(systemName: "chevron.right")
                .font(.system(size: 22, weight: .bold))
                .imageScale(.small)
                .foregroundStyle(.secondary)
        }
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

// MARK: - Data Types

extension ShoesTab {
    
    enum SheetType: Identifiable {
        case addShoe
        case setDefaultShoe
        case addToShoe(workoutID: UUID)
        
        var id: UUID {
            switch self {
            case .addShoe:
                return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
            case .setDefaultShoe:
                return UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
            case .addToShoe(let workoutID):
                return workoutID
            }
        }
        
        static func == (lhs: SheetType, rhs: SheetType) -> Bool {
                switch (lhs, rhs) {
                case (.addShoe, .addShoe), (.setDefaultShoe, .setDefaultShoe):
                    return true
                case let (.addToShoe(workout1), .addToShoe(workout2)):
                    return workout1 == workout2
                default:
                    return false
                }
            }
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


//StatCell(title: "Active Kilocalories", value: String(format: "%.0f", lastRun.activeKilocalories), unit: UnitEnergy.kilocalories.symbol, color: .pink)
