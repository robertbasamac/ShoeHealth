//
//  ShoeDetailView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.04.2024.
//

import SwiftUI
import HealthKit

struct ShoeDetailView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(\.dismiss) private var dismiss
    
    private var shoe: Shoe
    private var isFullScreen: Bool
    
    /// Used for navigaion and modals presentation
    @State private var showEditShoe: Bool = false
    @State private var showAllWorkouts: Bool = false
    @State private var showAddWorkouts: Bool = false
    @State private var showDeletionConfirmation: Bool = false
    @State private var showDefaultSelection: Bool = false
    
    /// Used for Header behavior
    @State private var opacity: CGFloat = 0
    @State private var navBarVisibility: Visibility = .hidden
    @State private var navBarTitle: String = ""
    
    private var isAnyModalPresented: Bool {
        showEditShoe || showAddWorkouts || showDefaultSelection
    }
    
    /// Used to calculate the bottom padding needed to be added to be able to fully scroll content until navigation bar becomes visible
    @State private var bottomPadding: CGFloat = 20
    @State private var sectionHeights: [String: CGFloat] = [:]
    private var storedNavBarHeight: CGFloat = UIApplication.navigationBarHeight
    
    @ScaledMetric(relativeTo: .largeTitle) private var progressCircleSize: CGFloat = 100
    
    init(shoe: Shoe, showStats: Bool = true, isFullScreen: Bool = false) {
        self.shoe = shoe
        self.isFullScreen = isFullScreen
    }
    
    var body: some View {
        Group {
            if let imageData = shoe.image {
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        StretchyHeaderCell(
                            height: 250,
                            model: shoe.model,
                            brand: shoe.brand,
                            nickname: shoe.nickname,
                            date: shoe.aquisitionDate,
                            imageData: imageData,
                        )
                        .overlay {
                            Color(uiColor: .systemBackground)
                                .opacity(Double(opacity))
                        }
                        .readingFrame { frame in
                            readFrame(frame)
                        }
                        
                        healthSection
                        statsSection
                        workoutsSection
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.stretchyHeader)
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        StaticHeaderCell(
                            model: shoe.model,
                            brand: shoe.brand,
                            nickname: shoe.nickname,
                            date: shoe.aquisitionDate
                        )
                        .frame(height: 110)
                        .overlay {
                            Color(uiColor: .systemBackground)
                                .opacity(Double(opacity))
                        }
                        .readingFrame { frame in
                            readFrame(frame)
                        }
                        
                        healthSection
                        statsSection
                        workoutsSection
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.staticHeader)
            }
        }
        .contentMargins(.bottom, bottomPadding)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(navBarTitle)
        .toolbarBackground(navBarVisibility, for: .navigationBar)
        .toolbar {
            toolbarItems
        }
        .onPreferenceChange(SectionHeightPreferenceKey.self) { heights in
            sectionHeights = heights
            computeBottomPadding()
        }
        .confirmationDialog(
            "Delete this shoe?",
            isPresented: $showDeletionConfirmation,
            titleVisibility: .visible,
            presenting: shoe,
            actions: { shoe in
                Button("Delete", role: .destructive) {
                    deleteShoe()
                }
            },
            message: { shoe in
                Text("Deleting \'\(shoe.brand) \(shoe.model) - \(shoe.nickname)\' shoe is permanent. This action cannot be undone.")
            })
        .navigationDestination(isPresented: $showAllWorkouts) {
            ShoeWorkoutsListView(shoe: shoe, isShoeRestricted: shoesViewModel.shouldRestrictShoe(shoe.id))
        }
        .sheet(isPresented: $showEditShoe) {
            NavigationStack {
                ShoeFormView(shoe: shoe)
            }
            .presentationCornerRadius(20)
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showDefaultSelection
               , onDismiss: {
            triggerSetNewDailyDefaultShoe()
        }) {
            NavigationStack {
                RunTypeSelectionView(selectedRunTypes: shoe.defaultRunTypes) { selectedRunTypes in
                    withAnimation {
                        shoesViewModel.setAsDefaultShoe(shoe.id, for: selectedRunTypes)
                    }
                    
                    NotificationManager.shared.setActionableNotificationTypes(isPremiumUser: storeManager.hasFullAccess)
                }
            }
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showAddWorkouts) {
            NavigationStack {
                AddWokoutsToShoeView(shoeID: shoe.id)
            }
            .presentationDragIndicator(.visible)
        }
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - View Components

extension ShoeDetailView {
    
    @ViewBuilder
    private var healthSection: some View {
        VStack(spacing: 0) {
            Text("Health")
                .asHeader()
            
            VStack(spacing: 0) {
                lifespanSection
                
                Rectangle()
                    .fill(.background)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                
                conditionSection
            }
            .roundedContainer()
        }
        .padding(.top, 8)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SectionHeightPreferenceKey.self, value: ["healthSection": geo.size.height])
            }
        )
    }
    
    @ViewBuilder
    private var statsSection: some View {
        VStack(spacing: 0) {
            Text("Statistics")
                .asHeader()
            
            VStack(spacing: 8) {
                averagesSection
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .fill(.background)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                
                personalBestsSection
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .roundedContainer()
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SectionHeightPreferenceKey.self, value: ["statsSection": geo.size.height])
            }
        )
    }
    
    @ViewBuilder
    private var workoutsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workouts")
                
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .asHeader()
            .onTapGesture {
                showAllWorkouts.toggle()
            }
            .overlay(alignment: .trailing, content: {
                Button {
                    showAddWorkouts.toggle()
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                .padding(.trailing, 20)
                .disabled(shoesViewModel.shouldRestrictShoe(shoe.id))
            })
            
            VStack(spacing: 4) {
                ForEach(getShoeMostRecentlyWorkouts()) { workout in
                    WorkoutListItem(workout: workout)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.theme.containerBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SectionHeightPreferenceKey.self, value: ["workoutsSection": geo.size.height])
            }
        )
    }
    
    @ViewBuilder
    private var lifespanSection: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                StatCell(
                    label: "Current",
                    value: shoe.totalDistance.as2DecimalsString(),
                    unit: settingsManager.unitOfMeasure.symbol,
                    color: .blue,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                StatCell(
                    label: "Remaining",
                    value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(),
                    unit: settingsManager.unitOfMeasure.symbol,
                    color: shoe.wearColor,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
            }
            
            ZStack {
                CircularProgressView(progress: shoe.wearPercentage, lineWidth: 6, color: shoe.wearColor)
                StatCell(
                    label: "Wear",
                    value: shoe.wearPercentageAsString(withDecimals: 1),
                    color: shoe.wearColor,
                    showLabel: false
                )
            }
            .frame(width: progressCircleSize, height: progressCircleSize)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var conditionSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: shoe.isRetired ? "bolt.slash" : shoe.wearCondition.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                    
                    VStack {
                        Text(shoe.isRetired ? "Retired" : shoe.wearCondition.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(shoe.isRetired ? .gray : shoe.wearColor)
                .padding(.leading, 10)
                
                VStack(spacing: 10) {
                    if shoe.isRetired {
                        Text("This shoe is retired since")
                        Text("\(dateFormatter.string(from: shoe.retireDate ?? .now))")
                    } else {
                        Text("\(shoe.wearCondition.description)")
                        Text("\(shoe.wearCondition.action)")
                    }
                }
                .font(.callout)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if shoe.wearCondition.rawValue > WearCondition.good.rawValue || shoe.isRetired {
                Button {
                    retireShoe()
                } label: {
                    Group {
                        if shoe.isRetired {
                            Text("Reinstate Shoe")
                        } else {
                            Text("Retire Shoe")
                        }
                    }
                    .font(.callout.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
                .tint(shoe.isRetired ? .green : .red)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 10))
            }
        }
        .padding(20)
    }
    
    @ViewBuilder
    private var averagesSection: some View {
        VStack(spacing: 8) {
            HStack {
                StatCell(
                    label: "Runs",
                    value: "\(shoe.workouts.count)",
                    color: .gray,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                StatCell(
                    label: "Avg Pace",
                    value: String(format: "%d'%02d\"", shoe.averagePace.minutes, shoe.averagePace.seconds),
                    unit: "/\(settingsManager.unitOfMeasure.symbol)",
                    color: .teal,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
            }
            
            Divider()
            
            HStack {
                StatCell(
                    label: "Total Distance",
                    value: shoe.totalDistance.as2DecimalsString(),
                    unit: settingsManager.unitOfMeasure.symbol,
                    color: .blue,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                StatCell(
                    label: "Avg Distance",
                    value: shoe.averageDistance.as2DecimalsString(),
                    unit: settingsManager.unitOfMeasure.symbol,
                    color: .blue,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
            }
            
            Divider()
            
            HStack {
                StatCell(
                    label: "Total Duration",
                    value: shoe.formattedTotalDuration,
                    color: .yellow,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                StatCell(
                    label: "Avg Duration",
                    value: shoe.formatterAverageDuration,
                    color: .yellow,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
            }
        }
    }
    
    @ViewBuilder
    private var personalBestsSection: some View {
        Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 4) {
            GridRow {
                Color.clear
                    .gridCellColumns(2)
                
                Text("PR")
                    .lineLimit(1)
                    .gridCellColumns(3)
                
                Text("Runs")
                    .lineLimit(1)
                    .gridCellColumns(2)
            }
            .font(.caption)
            .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxLarge)
            .foregroundStyle(.secondary)
            
            ForEach(RunningCategory.allCases, id: \.self) { category in
                GridRow {
                    Text("\(settingsManager.unitOfMeasure == .metric ? category.shortTitle : category.shortTitleInMiles)")
                        .font(.subheadline)
                        .fontDesign(.default)
                        .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxLarge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .gridCellColumns(2)
                    
                    Text(shoe.formattedPersonalBest(for: category))
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .gridCellColumns(3)
                    
                    Text("\(shoe.totalRuns[category] ?? 0)")
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .gridCellColumns(2)
                }
                .font(.headline)
                .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxxLarge)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: isFullScreen ? "xmark" : "chevron.left")
                    .imageScale(.large)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.blurredCircle(Double(1 - opacity)))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    showEditShoe.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .disabled(shoesViewModel.shouldRestrictShoe(shoe.id))
                
                Button {
                    showDefaultSelection.toggle()
                } label: {
                    Label("Set Default", systemImage: "figure.run")
                }
                
                Button(role: .destructive) {
                    showDeletionConfirmation.toggle()
                } label : {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 34, height: 34)
                    .background(.bar.opacity(Double(1 - opacity)), in: .circle)
            }
        }
    }
}

// MARK: - Helpers

extension ShoeDetailView {
    
    private func getShoeWorkouts() -> [HKWorkout] {
        return healthManager.getWorkouts(forIDs: shoe.workouts)
    }
    
    private func getShoeMostRecentlyWorkouts() -> [HKWorkout] {
        return Array(getShoeWorkouts().prefix(5))
    }
    
    private func retireShoe() {
        let setNewDefaultShoe = shoe.isDefaultShoe && shoe.defaultRunTypes.contains(.daily) && !shoe.isRetired
        
        withAnimation {
            shoesViewModel.retireShoe(shoe.id)
        }
        
        if setNewDefaultShoe && !shoesViewModel.shoes.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigationRouter.showSheet = .setDefaultShoe(forRunType: .daily)
            }
        }
    }
    
    private func deleteShoe() {
        let setNewDefaultShoe = shoe.isDefaultShoe && shoe.defaultRunTypes.contains(.daily)
        
        withAnimation {
            shoesViewModel.deleteShoe(shoe.id)
        }
        
        navigationRouter.deleteShoe(shoe.id)
        
        if setNewDefaultShoe && !shoesViewModel.shoes.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigationRouter.showSheet = .setDefaultShoe(forRunType: .daily)
            }
        }
    }
    
    private func triggerSetNewDailyDefaultShoe() {
        guard let _ = shoesViewModel.getDefaultShoe(for: .daily) else {
            if !shoesViewModel.shoes.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigationRouter.showSheet = .setDefaultShoe(forRunType: .daily)
                }
            }
            return
        }
    }
    
    private func computeBottomPadding() {
        let healthHeight = sectionHeights["healthSection"] ?? 0
        let statsHeight = sectionHeights["statsSection"] ?? 0
        let workoutsHeight = sectionHeights["workoutsSection"] ?? 0
        let screenHeight = UIScreen.main.bounds.size.height
        let statusBarHeight = UIApplication.statusBarHeight
        let bottomSafeAreaInsets = UIApplication.bottomSafeAreaInsets
        let tabBarHeight = isFullScreen ? (UIApplication.tabBarHeight - bottomSafeAreaInsets) : 0
        
        let availableHeight = screenHeight - statusBarHeight - bottomSafeAreaInsets - storedNavBarHeight - healthHeight - statsHeight - workoutsHeight + tabBarHeight
                
        bottomPadding = availableHeight < 20 ? 20 : availableHeight
    }
    
    private func readFrame(_ frame: CGRect) {
        guard frame.maxY > 0 && !isAnyModalPresented else {
            return
        }
        
        let topPadding: CGFloat = UIApplication.statusBarHeight + 44
        let showNavBarTitlePadding: CGFloat = 25
        
        opacity = interpolateOpacity(position: frame.maxY,
                                     minPosition: topPadding + showNavBarTitlePadding,
                                     maxPosition: topPadding + 110,
                                     reversed: true)
        
        navBarVisibility = frame.maxY < (topPadding - 0.5) ? .automatic : .hidden
        navBarTitle = frame.maxY < (topPadding + showNavBarTitlePadding) ? shoe.model : ""
    }
    
    private func interpolateOpacity(position: CGFloat, minPosition: CGFloat, maxPosition: CGFloat, reversed: Bool) -> Double {
        // Ensure position is within the range
        let clampedPosition = min(max(position, minPosition), maxPosition)
        
        // Calculate normalized position between 0 and 1
        let normalizedPosition = (clampedPosition - minPosition) / (maxPosition - minPosition)
        
        // Interpolate opacity between 0 and 1
        let interpolatedOpacity = reversed ? Double(1 - normalizedPosition) : Double(normalizedPosition)
        
        return interpolatedOpacity
    }
}

// MARK: - Preview

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailView(shoe: Shoe.previewShoes[3])
                .environmentObject(NavigationRouter())
                .environmentObject(StoreManager.shared)
                .environment(ShoesViewModel(shoeDataHandler: ShoeDataHandler(modelContext: PreviewSampleData.container.mainContext)))
                .environment(SettingsManager.shared)
                .environment(HealthManager.shared)
        }
    }
}
