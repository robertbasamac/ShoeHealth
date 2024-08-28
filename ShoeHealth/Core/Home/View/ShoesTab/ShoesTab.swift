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
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    @State private var selectedShoe: Shoe?
    @State private var selectedCategory: ShoeCategory?
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 12) {
                lastRunSection
                
                defaultShoeSection
                
                recentlyUsedSection
                
                activeShoesSection
                
                retiredShoesSection
            }
        }
        .navigationTitle("Shoe Health")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarItems
        }
        .navigationDestination(item: $selectedShoe) { shoe in
            ShoeDetailView(shoe: shoe)
        }
        .navigationDestination(item: $selectedCategory) { category in
            ShoesListView(shoes: shoesViewModel.getShoes(filter: category))
                .navigationTitle(category == .active ? "Active Shoes" : "Retired Shoes")
        }
        .onChange(of: unitOfMeasureString) { _, newValue in
            unitOfMeasure = UnitOfMeasure(rawValue: newValue) ?? .metric
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
            
            Group {
                if let lastRun = HealthManager.shared.getLastRun() {
                    VStack(spacing: 8) {
                        HStack {
                            runDateAndTimeSection(lastRun)
                            runUsedShoeSection(lastRun)
                        }
                        .padding(.horizontal, 20)
                        
                        Rectangle()
                            .fill(.background)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                        
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
    private var defaultShoeSection: some View {
        VStack(spacing: 0) {
            Text("Default Shoe")
                .asHeader()
            
            if let shoe = shoesViewModel.getDefaultShoe() {
                ShoeListItem(shoe: shoe)
                    .roundedContainer()
                    .onTapGesture {
                        selectedShoe = shoe
                    }
            } else {
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
                            navigationRouter.showSheet = .setDefaultShoe
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
        let shoes = shoesViewModel.getRecentlyUsedShoes()
        
        if !shoes.isEmpty {
            VStack(spacing: 0) {
                Text("Recently Used")
                    .asHeader()
                
                shoesCarousel(shoes: shoes)
            }
        }
    }
    
    @ViewBuilder
    private var activeShoesSection: some View {
        let shoes = shoesViewModel.getShoes(filter: .active)

        if !shoes.isEmpty {
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
                
                shoesCarousel(shoes: shoes)
            }
        }
    }
    
    @ViewBuilder
    private var retiredShoesSection: some View {
        let shoes = shoesViewModel.getShoes(filter: .retired)

        if !shoes.isEmpty {
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
                
                shoesCarousel(shoes: shoes)
            }
        }
    }
    
    @ViewBuilder
    private func shoesCarousel(shoes: [Shoe]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 6) {
                ForEach(shoes) { shoe in
                    ShoeCell(shoe: shoe, width: 140)
                        .contextMenu {
                            if !shoe.isDefaultShoe {
                                Button {
                                    shoesViewModel.setAsDefaultShoe(shoe.id)
                                } label: {
                                    Label("Set Default", systemImage: "shoe.2")
                                }
                            }
                            
                            Button {
                                let wasDefaultShoe = shoe.isDefaultShoe

                                shoesViewModel.retireShoe(shoe.id)
                                
                                if wasDefaultShoe {
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
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    shoesViewModel.deleteShoe(shoe.id)
                                }
                                
                                if shoe.isDefaultShoe && !shoesViewModel.shoes.isEmpty {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        navigationRouter.showSheet = .setDefaultShoe
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } preview: {
                            ShoeCell(shoe: shoe, width: 300, displayProgress: false, reserveSpace: false)
                                .padding(10)
                        }
                        .onTapGesture {
                            selectedShoe = shoe
                        }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func runDateAndTimeSection(_ run: HKWorkout) -> some View {
        VStack(alignment: .center) {
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
                StatCell(label: "Duration", value: run.durationAsString, color: .yellow, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Distance", value: String(format: "%.2f", run.totalDistance(unit: unitOfMeasure.unit)), unit: unitOfMeasure.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Avg Power", value: String(format: "%0.0f", run.averagePower), unit: UnitPower.watts.symbol, color: .accentColor, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Cadence", value: String(format: "%.0f", run.averageCadence), unit: "SPM", color: .cyan, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Avg Pace", value: String(format: "%d'%02d\"", run.averagePace(unit: unitOfMeasure.unit).minutes, run.averagePace(unit: unitOfMeasure.unit).seconds), unit: "/\(unitOfMeasure.symbol)", color: .teal, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Heart Rate", value: String(format: "%.0f", run.averageHeartRate), unit: "BPM", color: .red, textAlignment: .leading, containerAlignment: .leading)
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
                .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .font(.title2.bold())
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
                .onTapGesture {
                    selectedShoe = shoe
                }
            } else {
                Text("No shoe selected for this workout.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.center)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        navigationRouter.showSheet = .addWorkoutToShoe(workoutID: run.id)
                    }
            }
        }
        .overlay(alignment: .leading) {
            Image(systemName: "shoe.2.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .offset(x: -50)
        }
    }
    
    @ViewBuilder
    private func swipeRightActions(shoe: Shoe) -> some View {
        Button {
            let wasDefaultShoe = shoe.isDefaultShoe
            
            shoesViewModel.retireShoe(shoe.id)
            
            if wasDefaultShoe {
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
                navigationRouter.showSheet = .setDefaultShoe
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
//        ToolbarItem(placement: .principal) {
//            VStack(spacing: 0) {
//                Image(systemName: "shoe.fill")
//                    .font(.system(size: 17))
//                    .foregroundStyle(.accent)
//                
//                Text("Health")
//                    .font(.headline)
//                    .minimumScaleFactor(0.5)
//            }
//        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                navigationRouter.showSheet = .addShoe
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
