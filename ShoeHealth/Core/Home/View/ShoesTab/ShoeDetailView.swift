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
    
    @Namespace private var namespace
    
    private var shoe: Shoe
    private var isFullScreen: Bool
    
    /// Used for navigation and modals presentation
    @State private var showAllWorkouts: Bool = false
    @State private var showDeletionConfirmation: Bool = false
    @State private var activeSheet: ActiveSheet?
    
    /// Used for Header behavior
    @State private var opacity: CGFloat = 0
    @State private var navBarVisibility: Visibility = .hidden
    @State private var navBarTitle: String = ""
    @State private var navBarSubtitle: String = ""
    
    /// Used to calculate the bottom padding needed to be added to be able to fully scroll content until navigation bar becomes visible
    @State private var bottomPadding: CGFloat = 20
    @State private var sectionHeights: [String: CGFloat] = [:]
    private var storedNavBarHeight: CGFloat = UIApplication.navigationBarHeight
    
    init(shoe: Shoe, showStats: Bool = true, isFullScreen: Bool = false) {
        self.shoe = shoe
        self.isFullScreen = isFullScreen
    }

    private enum ActiveSheet: Hashable, Identifiable {
        case editShoe
        case defaultSelection
        case addWorkouts

        var id: Self { self }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                StretchyHeaderCell(
                    height: 250,
                    model: shoe.model,
                    brand: shoe.brand,
                    nickname: shoe.nickname,
                    date: shoe.aquisitionDate,
                    imageData: shoe.image
                )
                .overlay {
                    Color(uiColor: .systemBackground)
                        .opacity(Double(opacity))
                }
                .readingFrame { frame in
                    readFrame(frame)
                }

                HealthSectionView(shoe: shoe)
                StatsSectionView(shoe: shoe)
                WorkoutsSectionView(shoe: shoe, showAllWorkouts: $showAllWorkouts) {
                    activeSheet = .addWorkouts
                }
            }
        }
        .scrollTargetBehavior(.dynamicStretchyHeader(for: shoe))
        .contentMargins(.bottom, bottomPadding)
        .adaptToPreiOS26(navBarVisibility: navBarVisibility, navBarTitle: navBarTitle, navBarSubtitle: navBarSubtitle)
        .toolbar {
            toolbarItems
        }
        .onPreferenceChange(SectionHeightPreferenceKey.self) { heights in
            sectionHeights = heights
            computeBottomPadding()
        }
        .navigationDestination(isPresented: $showAllWorkouts) {
            ShoeWorkoutsListView(shoe: shoe, isShoeRestricted: shoesViewModel.shouldRestrictShoe(shoe.id))
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .editShoe:
                if #available(iOS 26.0, *) {
                    NavigationStack {
                        ShoeFormView(shoe: shoe)
                    }
                    .presentationCornerRadius(20)
                    .interactiveDismissDisabled()
                    .navigationTransition(
                        .zoom(sourceID: "transition-id", in: namespace)
                    )
                } else {
                    NavigationStack {
                        ShoeFormView(shoe: shoe)
                    }
                    .presentationCornerRadius(20)
                    .interactiveDismissDisabled()
                }

            case .defaultSelection:
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
                .onDisappear {
                    triggerSetNewDailyDefaultShoe()
                }

            case .addWorkouts:
                NavigationStack {
                    AddWokoutsToShoeView(shoeID: shoe.id)
                }
                .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - View Components

extension ShoeDetailView {
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        let content = Group {
            ToolbarItem(placement: .cancellationAction) {
                if #available(iOS 26, *) {
                    if isFullScreen {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    } else {
                        EmptyView()
                    }
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: isFullScreen ? "xmark" : "chevron.left")
                            .imageScale(.large)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.blurredCircle(Double(1 - opacity)))
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        activeSheet = .editShoe
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .disabled(shoesViewModel.shouldRestrictShoe(shoe.id))

                    Button {
                        activeSheet = .defaultSelection
                    } label: {
                        Label("Set Default", systemImage: "figure.run")
                    }
                    
                    Button(role: .destructive) {
                        showDeletionConfirmation.toggle()
                    } label : {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    if #available(iOS 26, *) {
                        Image(systemName: "ellipsis")
                    } else {
                        Image(systemName: "ellipsis")
                            .frame(width: 34, height: 34)
                            .background(.bar.opacity(Double(1 - opacity)), in: .circle)
                    }
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
            }
        }
        
        if #available(iOS 26, *) {
            content.matchedTransitionSource(id: "transition-id", in: namespace)
        } else {
            content
        }
    }
}

// MARK: - Helper Methods

extension ShoeDetailView {
    
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
        guard frame.maxY > 0 && activeSheet == nil else {
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
        navBarSubtitle = frame.maxY < (topPadding + showNavBarTitlePadding) ? shoe.nickname : ""
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
            ShoeDetailView(shoe: Shoe.previewShoes[1])
                .environmentObject(NavigationRouter())
                .environmentObject(StoreManager.shared)
                .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.container.mainContext)))
                .environment(SettingsManager.shared)
                .environment(HealthManager.shared)
        }
    }
}


// MARK: - HealthSectionView

fileprivate struct HealthSectionView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(SettingsManager.self) private var settingsManager
    
    @ScaledMetric(relativeTo: .largeTitle) private var progressCircleSize: CGFloat = 80
    
    private var cappedProgressCircleSize: CGFloat {
        min(progressCircleSize, 94)
    }
    
    @ScaledMetric(relativeTo: .largeTitle) private var conditionImageSize: CGFloat = 34
    
    private var cappedImageSize: CGFloat {
        min(conditionImageSize, 40)
    }
    
    var shoe: Shoe
    
    var body: some View {
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
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2)
                    .dynamicTypeSize(DynamicTypeSize.small...DynamicTypeSize.large)
                }
                .tint(shoe.isRetired ? .green : .red)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.horizontal, 20)
            }
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
    private var lifespanSection: some View {
        HStack(spacing: 8) {
            StatCell(
                label: "Covered",
                value: shoe.totalDistance.asString(withDecimals: 1),
                unit: settingsManager.unitOfMeasure.symbol,
                color: .blue,
                textAlignment: .center,
                containerAlignment: .center,
                valueOnTop: true
            )
            
            ZStack {
                CircularProgressView(progress: shoe.wearPercentage, lineWidth: 6, color: shoe.wearColor)
                StatCell(
                    label: "Wear",
                    value: shoe.wearPercentageAsString(withDecimals: 0),
                    color: shoe.wearColor,
                    showLabel: false
                )
            }
            .frame(width: cappedProgressCircleSize, height: cappedProgressCircleSize)
            
            StatCell(
                label: "Remaining",
                value: (shoe.lifespanDistance - shoe.totalDistance).asString(withDecimals: 1),
                unit: settingsManager.unitOfMeasure.symbol,
                color: shoe.wearColor,
                textAlignment: .center,
                containerAlignment: .center,
                valueOnTop: true
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var conditionSection: some View {
        
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Condition")
                    .font(.footnote)
                    .fontWeight(.bold)

                HStack(spacing: 8) {
                    Image(systemName: shoe.wearCondition.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: cappedImageSize, height: cappedImageSize)
                        .foregroundStyle(shoe.wearColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if !shoe.isRetired {
                            Text("\(shoe.wearCondition.action)")
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(0)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        
                        Text(shoe.wearCondition.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(shoe.wearColor)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 10)

            Rectangle()
                .fill(.background)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Retirement")
                    .font(.footnote)
                    .fontWeight(.bold)

                if shoe.isRetired {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Retired since")
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(0)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                } else if let estimatedDate = shoesViewModel.estimatedRetirementDate(for: shoe) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimated Date")
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(0)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        Text(estimatedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimated Date")
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(0)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        Text("N/A")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 10)
        }
        .padding(.horizontal, 20)
        .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxLarge)
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
}

// MARK: - StatsSectionView

fileprivate struct StatsSectionView: View {
    
    @Environment(SettingsManager.self) private var settingsManager
    
    var shoe: Shoe
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Statistics")
                .asHeader()
            
            VStack(spacing: 10) {
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
                    value: shoe.totalDistance.asString(withDecimals: 2),
                    unit: settingsManager.unitOfMeasure.symbol,
                    color: .blue,
                    textAlignment: .leading,
                    containerAlignment: .leading
                )
                StatCell(
                    label: "Avg Distance",
                    value: shoe.averageDistance.asString(withDecimals: 2),
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
}

// MARK: - WorkoutsSectionView

fileprivate struct WorkoutsSectionView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    
    var shoe: Shoe
    
    @Binding var showAllWorkouts: Bool
    var openAddWorkouts: () -> Void

    var body: some View {
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
                    openAddWorkouts()
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
                        .background(Color.theme.containerBackground, in: RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous))
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
    
    private func getShoeWorkouts() -> [HKWorkout] {
        return healthManager.getWorkouts(forIDs: shoe.workouts)
    }
    
    private func getShoeMostRecentlyWorkouts() -> [HKWorkout] {
        return Array(getShoeWorkouts().prefix(5))
    }
}

// MARK: - View Extension

fileprivate extension View {
    
    @ViewBuilder
    func adaptToPreiOS26(navBarVisibility: Visibility, navBarTitle: String, navBarSubtitle: String) -> some View {
        if #available(iOS 26, *) {
            self.navigationTitle(navBarTitle)
                .navigationSubtitle(navBarSubtitle)
        } else if #available(iOS 18, *) {
            self.navigationBarBackButtonHidden()
                .toolbarBackgroundVisibility(navBarVisibility, for: .navigationBar)
                .navigationBarTitle(navBarTitle, displayMode: .inline)
        } else {
            self.navigationBarBackButtonHidden()
                .toolbarBackground(navBarVisibility, for: .navigationBar)
                .navigationBarTitle(navBarTitle, displayMode: .inline)
        }
    }
}
