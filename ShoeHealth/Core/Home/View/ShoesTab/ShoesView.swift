//
//  ShoesView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 24.10.2024.
//

import SwiftUI
import HealthKit

struct ShoesView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    @Environment(SettingsManager.self) private var settingsManager
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    
    @State private var showDeletionConfirmation: Bool = false
    @State private var shoeForDeletion: Shoe? = nil
    
    @ScaledMetric(relativeTo: .largeTitle) private var width: CGFloat = 140
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                lastRunSection
                
                defaultShoeSection
                
                recentlyUsedSection
                
                activeShoesSection
                
                retiredShoesSection
            }
        }
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
        .toolbar {
            toolbarItems
        }
        .navigationDestination(for: Shoe.self) { shoe in
            ShoeDetailView(shoe: shoe)
        }
        .navigationDestination(for: ShoeCategory.self) { category in
            ShoesListView(forCategory: category)
        }
        .refreshable {
            await healthManager.fetchRunningWorkouts()
        }
    }
}

// MARK: - View Components

extension ShoesView {
    
    @ViewBuilder
    private var lastRunSection: some View {
        VStack(spacing: 0) {
            Text("Last Run")
                .asHeader()
            
            Group {
                if let lastRun = healthManager.getLastRun() {
                    VStack(spacing: 8) {
                        HStack {
                            runDateAndTimeSection(lastRun.workout)
                            runUsedShoeSection(lastRun.workout)
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
                ShoeListItem(shoe: shoe, width: width)
                    .roundedContainer()
                    .disabled(isShoeRestricted(shoe.id))
                    .onTapGesture {
                        dismissSearch()
                        navigationRouter.navigate(to: .shoe(shoe))
                    }
            } else {
                HStack(spacing: 0) {
                    ShoeImage(width: width)
                        .frame(width: width, height: width)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack {
                        Text("No Default Shoe")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            if shoesViewModel.shoes.isEmpty {
                                navigationRouter.showSheet = .addShoe
                            } else {
                                navigationRouter.showSheet = .setDefaultShoe
                            }
                        } label: {
                            if shoesViewModel.shoes.isEmpty {
                                Text("Add Shoe")
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                            } else {
                                Text("Select Shoe")
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                            }
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
        let shoes = shoesViewModel.getShoes(for: .active)

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
                    dismissSearch()
                    navigationRouter.navigate(to: .category(.active))
                }
                
                shoesCarousel(shoes: shoes)
            }
        }
    }
    
    @ViewBuilder
    private var retiredShoesSection: some View {
        let shoes = shoesViewModel.getShoes(for: .retired)

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
                    dismissSearch()
                    navigationRouter.navigate(to: .category(.retired))
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
                    ShoeCell(shoe: shoe, width: width)
                        .disabled(isShoeRestricted(shoe.id))
                        .contextMenu {
                            if !shoe.isDefaultShoe && !isShoeRestricted(shoe.id) {
                                Button {
                                    withAnimation {
                                        shoesViewModel.setAsDefaultShoe(shoe.id)
                                    }
                                } label: {
                                    Label("Set Default", systemImage: "shoe.2")
                                }
                            }
                            
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
                            
                            Button(role: .destructive) {
                                shoeForDeletion = shoe
                                showDeletionConfirmation.toggle()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } preview: {
                            if shoe.image == nil {
                                ShoeCell(shoe: shoe, width: 150, hideImage: true, displayProgress: false, reserveSpace: false)
                                    .padding(10)
                            } else {
                                ShoeCell(shoe: shoe, width: 300, displayProgress: false, reserveSpace: false)
                                    .padding(10)
                            }
                        }
                        .onTapGesture {
                            dismissSearch()
                            navigationRouter.navigate(to: .shoe(shoe))
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 20)
        .contentMargins(.vertical, 8)
    }
    
    @ViewBuilder
    private func runDateAndTimeSection(_ run: HKWorkout) -> some View {
        VStack(alignment: .center) {
            Text(run.startDateAsString)
            Text("\(run.startTimeAsString) - \(run.endTimeAsString)")
                .foregroundStyle(.secondary)
                .textScale(.secondary)
        }
        .font(.callout)
        .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func runStatsSection(_ run: RunningWorkout) -> some View {
        VStack(spacing: 8) {
            HStack {
                StatCell(
                    label: "Duration",
                    value: run.workout.durationAsString,
                    color: .yellow,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                
                StatCell(
                    label: "Distance",
                    value: String(
                        format: "%.2f",
                        run.workout.totalDistance(unit: settingsManager.unitOfMeasure.unit)
                    ),
                    unit: settingsManager.unitOfMeasure.symbol,
                    color: .blue,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
            }
            
            Divider()
            
            HStack {
                StatCell(
                    label: "Avg Power",
                    value: String(
                        format: "%0.0f",
                        run.wrappedAveragePower
                    ),
                    unit: UnitPower.watts.symbol,
                    color: Color.theme.greenEnergy,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                
                StatCell(
                    label: "Avg Cadence",
                    value: String(
                        format: "%.0f",
                        run.wrappedAverageCadence
                    ),
                    unit: "SPM",
                    color: .cyan,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
            }
            
            Divider()
            
            HStack {
                StatCell(
                    label: "Avg Pace",
                    value: String(
                        format: "%d'%02d\"",
                        run.workout.averagePace(unit: settingsManager.unitOfMeasure.unit).minutes,
                        run.workout.averagePace(unit: settingsManager.unitOfMeasure.unit).seconds
                    ),
                    unit: "/\(settingsManager.unitOfMeasure.symbol)",
                    color: .teal,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                
                StatCell(
                    label: "Avg Heart Rate",
                    value: String(
                        format: "%.0f",
                        run.wrappedAverageHeartRate
                    ),
                    unit: "BPM",
                    color: .red,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
            }
        }
    }
    
    @ViewBuilder
    private func runUsedShoeSection(_ run: HKWorkout) -> some View {
        Group {
            if let shoe = shoesViewModel.getShoe(ofWorkoutID: run.id) {
                VStack(alignment: .leading) {
                    Text("\(shoe.brand)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("\(shoe.model)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                }
                .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxxLarge)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 30)
                .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .font(.title2.bold())
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
                .onTapGesture {
                    dismissSearch()
                    navigationRouter.navigate(to: .shoe(shoe))
                }
            } else {
                Text("No shoe selected for this workout")
                    .font(.callout)
                    .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxLarge)

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.center)
                    .padding(.trailing, 30)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        dismissSearch()
                        navigationRouter.showSheet = .addWorkoutToShoe(workoutID: run.id)
                    }
            }
        }
//        .overlay(alignment: .leading) {
//            Image(systemName: "shoe.2.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 44, height: 44)
//                .offset(x: -50)
//        }
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
            
            navigationRouter.deleteShoe(shoe.id)
            
            if shoe.isDefaultShoe && !shoesViewModel.shoes.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigationRouter.showSheet = .setDefaultShoe
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
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
                    Label("Sort Order", systemImage: shoesViewModel.sortingOrder == .forward ? "arrow.up" : "arrow.down")
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .imageScale(.medium)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                if storeManager.hasFullAccess || !shoesViewModel.isShoesLimitReached() {
                    navigationRouter.showSheet = .addShoe
                } else {
                    navigationRouter.showLimitAlert.toggle()
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Helper Methods

extension ShoesView {
    
    private func isShoeRestricted(_ shoeID: UUID) -> Bool {
        return !storeManager.hasFullAccess && shoesViewModel.shouldRestrictShoe(shoeID)
    }
}

// MARK: - Preview

#Preview("Filled") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.container)
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager())
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
            .environment(SettingsManager.shared)
            .environment(HealthManager.shared)
    }
}

#Preview("Empty") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.emptyContainer)
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager())
            .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
            .environment(SettingsManager.shared)
            .environment(HealthManager.shared)
    }
}
