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
    @Environment(\.openURL) private var openURL
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    
    @State private var showDeletionConfirmationDefault: Bool = false
    @State private var showDeletionConfirmationRecently: Bool = false
    @State private var showDeletionConfirmationActive: Bool = false
    @State private var showDeletionConfirmationRetired: Bool = false

    @State private var shoeForDeletion: Shoe? = nil
    @State private var shoeForRunTypesSelection: Shoe? = nil
    
    @State private var selectedDefaulRunType: RunType = .daily
    
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
        .sheet(item: $shoeForRunTypesSelection, onDismiss: {
            triggerSetNewDailyDefaultShoe()
        }) { shoe in
            DynamicSheet(animation: .smooth) {
                RunTypeSelectionView(selectedDefaultRunTypes: shoe.defaultRunTypes, selectedSuitableRunTypes: shoe.suitableRunTypes, preventDeselectingDaily: false) { selectedDefaultTypes, selectedSuitableTypes in
                    withAnimation {
                        shoesViewModel.setAsDefaultShoe(shoe.id, for: selectedDefaultTypes)
                        shoesViewModel.setSuitableRunTypes(selectedSuitableTypes, for: shoe.id)
                    }
                    NotificationManager.shared.setActionableNotificationTypes(isPremiumUser: storeManager.hasFullAccess)
                }
            }
        }
        .toolbar {
            toolbarItems
        }
        .navigationDestination(for: Shoe.self) { shoe in
            ShoeDetailView(shoe: shoe)
        }
        .navigationDestination(for: ShoeCategory.self) { category in
            ShoesListView(forCategory: category)
        }
        .onChange(of: storeManager.hasFullAccess, { _, newValue in
            selectedDefaulRunType = newValue ? .daily : selectedDefaulRunType
        })
        .refreshable {
            await healthManager.fetchRunningWorkouts()
        }
    }
}

// MARK: - View Components

extension ShoesView {
    
    // MARK: lastRunSection
    
    @ViewBuilder
    private var lastRunSection: some View {
        SectionBlock(title: "Last Run", rounded: true) {
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
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 56, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.top, 4)

                        VStack(spacing: 6) {
                            Text("No runs yet")
                                .font(.headline)
                            
                            Text("When you record a run in Apple Health, it will show up here.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 6) {
                            Button {
                                Task { await healthManager.fetchRunningWorkouts() }
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            
                            Text("or pull down to refresh")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 12)
                }
            }
        }
    }
    
    // MARK: defaultShoeSection
    
    @ViewBuilder
    private var defaultShoeSection: some View {
        SectionBlock(title: "Default Shoes") {
            VStack(spacing: 0) {
                HStack(spacing: RunTypeCapsule.capsuleSpace) {
                    ForEach(RunType.allCases, id: \.self) { runType in
                        RunTypeCapsule(
                            runType: runType,
                            foregroundColor: isFeatureDisabled(for: runType) ? Color.gray : (selectedDefaulRunType == runType ? Color.black : Color.primary),
                            backgroundColor: selectedDefaulRunType == runType ? Color.theme.accent : Color.theme.containerBackground) {
                                if isFeatureDisabled(for: runType) {
                                    navigationRouter.showFeatureRestrictedAlert(.defaultRunRestricted)
                                } else {
                                    if selectedDefaulRunType == runType {
                                        navigationRouter.showSheet = .setDefaultShoe(forRunType: runType)
                                    } else {
                                        selectedDefaulRunType = runType
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Group {
                    if let shoe = shoesViewModel.getDefaultShoe(for: selectedDefaulRunType) {
                        ShoeListItem(shoe: shoe, width: width)
                            .roundedContainer()
                            .disabled(shoesViewModel.shouldRestrictShoe(shoe.id))
                            .contextMenu {
                                setRunTypes(forShoe: shoe)
                                retireReinstateButton(forShoe: shoe)
                                deleteButton(forShoe: shoe)
                            } preview: {
                                contextMenuPreview(forShoe: shoe)
                            }
                            .onTapGesture {
                                dismissSearch()
                                navigationRouter.navigate(to: .shoe(shoe))
                            }
                    } else {
                        HStack(spacing: 0) {
                            ShoeImage(width: width)
                                .frame(width: width, height: width)
                                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous))
                            
                            VStack {
                                Group {
                                    Text("No default shoe selected for ") +
                                    Text("\(selectedDefaulRunType.rawValue.capitalized) runs")
                                }
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                
                                Button {
                                    if shoesViewModel.shoes.isEmpty {
                                        navigationRouter.showSheet = .addShoe
                                    } else {
                                        navigationRouter.showSheet = .setDefaultShoe(forRunType: selectedDefaulRunType)
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
                .confirmationDialog(
                    "Delete this shoe?",
                    isPresented: $showDeletionConfirmationDefault,
                    titleVisibility: .visible,
                    presenting: shoeForDeletion,
                    actions: { shoe in
                        confirmationActions(shoe: shoe)
                    },
                    message: { shoe in
                        Text("Deleting \'\(shoe.brand) \(shoe.model) - \(shoe.nickname)\' shoe is permanent. This action cannot be undone.")
                    })
            }
        }
    }
    
    // MARK: recentlyUsedSection
    
    @ViewBuilder
    private var recentlyUsedSection: some View {
        let shoes = shoesViewModel.getRecentlyUsedShoes()
        if !shoes.isEmpty {
            SectionBlock(title: "Recently Used") {
                ShoesHorizontalListView(
                    shoes: shoes,
                    width: width,
                    onTap: { shoe in
                        dismissSearch()
                        navigationRouter.navigate(to: .shoe(shoe))
                    },
                    onSetDefault: { shoe in
                        shoeForRunTypesSelection = shoe
                    },
                    onRetireToggle: { shoe in
                        let setNewDefaultShoe = shoe.isDefaultShoe && shoe.defaultRunTypes.contains(.daily) && !shoe.isRetired
                        withAnimation {
                            shoesViewModel.retireShoe(shoe.id)
                        }
                        if setNewDefaultShoe && !shoesViewModel.shoes.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                navigationRouter.showSheet = .setDefaultShoe(forRunType: .daily)
                            }
                        }
                    },
                    onDeleteRequest: { shoe in
                        shoeForDeletion = shoe
                        showDeletionConfirmationRecently.toggle()
                    }
                )
                .confirmationDialog(
                    "Delete this shoe?",
                    isPresented: $showDeletionConfirmationRecently,
                    titleVisibility: .visible,
                    presenting: shoeForDeletion,
                    actions: { shoe in
                        confirmationActions(shoe: shoe)
                    },
                    message: { shoe in
                        Text("Deleting \'\(shoe.brand) \(shoe.model) - \(shoe.nickname)\' shoe is permanent. This action cannot be undone.")
                    })
            }
        }
    }
    
    // MARK: activeShoesSection
    
    @ViewBuilder
    private var activeShoesSection: some View {
        let shoes = shoesViewModel.getShoes(for: .active)
        if !shoes.isEmpty {
            SectionBlock(title: "Active Shoes", onTap: {
                dismissSearch()
                navigationRouter.navigate(to: .category(.active))
            }) {
                ShoesHorizontalListView(
                    shoes: shoes,
                    width: width,
                    onTap: { shoe in
                        dismissSearch()
                        navigationRouter.navigate(to: .shoe(shoe))
                    },
                    onSetDefault: { shoe in
                        shoeForRunTypesSelection = shoe
                    },
                    onRetireToggle: { shoe in
                        let setNewDefaultShoe = shoe.isDefaultShoe && shoe.defaultRunTypes.contains(.daily) && !shoe.isRetired
                        withAnimation {
                            shoesViewModel.retireShoe(shoe.id)
                        }
                        if setNewDefaultShoe && !shoesViewModel.shoes.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                navigationRouter.showSheet = .setDefaultShoe(forRunType: .daily)
                            }
                        }
                    },
                    onDeleteRequest: { shoe in
                        shoeForDeletion = shoe
                        showDeletionConfirmationActive.toggle()
                    }
                )
                .confirmationDialog(
                    "Delete this shoe?",
                    isPresented: $showDeletionConfirmationActive,
                    titleVisibility: .visible,
                    presenting: shoeForDeletion,
                    actions: { shoe in
                        confirmationActions(shoe: shoe)
                    },
                    message: { shoe in
                        Text("Deleting \'\(shoe.brand) \(shoe.model) - \(shoe.nickname)\' shoe is permanent. This action cannot be undone.")
                    })
            }
        }
    }
    
    // MARK: retiredShoesSection
    
    @ViewBuilder
    private var retiredShoesSection: some View {
        let shoes = shoesViewModel.getShoes(for: .retired)
        if !shoes.isEmpty {
            SectionBlock(title: "Retired Shoes", onTap: {
                dismissSearch()
                navigationRouter.navigate(to: .category(.retired))
            }) {
                ShoesHorizontalListView(
                    shoes: shoes,
                    width: width,
                    onTap: { shoe in
                        dismissSearch()
                        navigationRouter.navigate(to: .shoe(shoe))
                    },
                    onSetDefault: { shoe in
                        shoeForRunTypesSelection = shoe
                    },
                    onRetireToggle: { shoe in
                        onRetireAction(forShoe: shoe)
                    },
                    onDeleteRequest: { shoe in
                        shoeForDeletion = shoe
                        showDeletionConfirmationRetired.toggle()
                    }
                )
                .confirmationDialog(
                    "Delete this shoe?",
                    isPresented: $showDeletionConfirmationRetired,
                    titleVisibility: .visible,
                    presenting: shoeForDeletion,
                    actions: { shoe in
                        confirmationActions(shoe: shoe)
                    },
                    message: { shoe in
                        Text("Deleting \'\(shoe.brand) \(shoe.model) - \(shoe.nickname)\' shoe is permanent. This action cannot be undone.")
                    })
            }
        }
    }
    
    // MARK: runDateAndTimeSection
    
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
    
    // MARK: runStatsSection
    
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
    
    // MARK: runUsedShoeSection
    
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
    
    // MARK: Context Menu Buttons
    
    @ViewBuilder
    private func setRunTypes(forShoe shoe: Shoe) -> some View {
        Button {
            shoeForRunTypesSelection = shoe
        } label: {
            Label("Set Run Types", systemImage: "figure.run")
        }
    }
    
    @ViewBuilder
    private func retireReinstateButton(forShoe shoe: Shoe) -> some View {
        Button {
            onRetireAction(forShoe: shoe)
        } label: {
            if shoe.isRetired {
                Label("Reinstate", systemImage: "bolt.fill")
            } else {
                Label("Retire", systemImage: "bolt.slash.fill")
            }
        }
    }
    
    @ViewBuilder
    private func deleteButton(forShoe shoe: Shoe) -> some View {
        Button(role: .destructive) {
            shoeForDeletion = shoe
            showDeletionConfirmationDefault.toggle()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    // MARK: confirmationActions
    
    @ViewBuilder
    private func confirmationActions(shoe: Shoe) -> some View {
        Button("Delete", role: .destructive) {
            shoeForDeletion = nil
            
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
    }
    
    // MARK: contextMenuPreview
    
    @ViewBuilder
    private func contextMenuPreview(forShoe shoe: Shoe) -> some View {
        if shoe.image == nil {
            ShoeCell(shoe: shoe, width: 150, cornerRadius: Constants.defaultCornerRadius, hideImage: true, displayProgress: false, reserveSpace: false)
                .padding(10)
        } else {
            ShoeCell(shoe: shoe, width: 300, cornerRadius: Constants.defaultCornerRadius, displayProgress: false, reserveSpace: false)
                .padding(10)
        }
    }
    
    // MARK: toolbarItems
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Sorting", selection: shoesViewModel.sortingOptionBinding) {
                    ForEach(SortingOption.allCases) { option in
                        if #available(iOS 26, *) {
                            Button { /* action */ } label: {
                                Text(option.rawValue)
                                if shoesViewModel.sortingOption == option {
                                    Text(shoesViewModel.isSortingAscending ? "Ascending" : "Descending")
                                }
                            }
                            .tag(option)
                        } else {
                            HStack {
                                Text(option.rawValue)
                                Spacer()
                                if shoesViewModel.sortingOption == option {
                                    Image(systemName: shoesViewModel.isSortingAscending ? "chevron.down" : "chevron.up")
                                }
                            }
                            .tag(option)
                        }
                    }
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
                    navigationRouter.showFeatureRestrictedAlert(.limitReached)
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Section Header & Block

fileprivate struct SectionHeader<Accessory: View>: View {
    
    let title: LocalizedStringKey
    let onTap: (() -> Void)?
    @ViewBuilder var accessory: () -> Accessory

    init(
        _ title: LocalizedStringKey,
        onTap: (() -> Void)? = nil,
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.onTap = onTap
        self.accessory = accessory
    }

    var body: some View {
        HStack {
            Text(title)
            accessory()
        }
        .asHeader()
        .contentShape(.rect)
        .onTapGesture {
            onTap?()
        }
    }
}

fileprivate extension SectionHeader where Accessory == EmptyView {

    init(
        _ title: LocalizedStringKey,
        onTap: (() -> Void)? = nil
    ) {
        self.init(
            title,
            onTap: onTap,
            accessory: {
                EmptyView()
            })
    }
}

fileprivate struct SectionBlock<Header: View, Content: View>: View {
    
    private let rounded: Bool
    private let header: Header
    private let content: Content

    init(
        rounded: Bool = false,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.rounded = rounded
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if rounded {
                content.roundedContainer()
            } else {
                content
            }
        }
    }
}

// Title-only
extension SectionBlock where Header == SectionHeader<EmptyView> {
    
    init(
        title: LocalizedStringKey,
        rounded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            rounded: rounded,
            header: {
                SectionHeader(title)
            },
            content: content)
    }
}

// Tappable title with chevron accessory
extension SectionBlock where Header == SectionHeader<AnyView> {
    
    init(
        title: LocalizedStringKey,
        rounded: Bool = false,
        onTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            rounded: rounded,
            header: {
                SectionHeader(
                    title,
                    onTap: onTap
                ) {
                    AnyView(
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    )
                }
            },
            content: content)
    }
}

// MARK: - Helper Methods

extension ShoesView {

    private func requestHealthAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        let authorization = await healthManager.requestAuthorization()
        return authorization
    }

    private func isFeatureDisabled(for runType: RunType) -> Bool {
        return runType != .daily && !storeManager.hasFullAccess
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
    
    private func onRetireAction(forShoe shoe: Shoe) {
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

// MARK: - Preview

#Preview("Filled") {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoesTab()
                .navigationTitle("Shoes")
                .modelContainer(PreviewSampleData.container)
                .environmentObject(NavigationRouter())
                .environmentObject(StoreManager.shared)
                .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.container.mainContext)))
                .environment(SettingsManager.shared)
                .environment(HealthManager.shared)
        }
    }
}

#Preview("Empty") {
    ModelContainerPreview(PreviewSampleData.emptyInMemoryContainer) {
        NavigationStack {
            ShoesTab()
                .navigationTitle("Shoes")
                .modelContainer(PreviewSampleData.emptyContainer)
                .environmentObject(NavigationRouter())
                .environmentObject(StoreManager.shared)
                .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.emptyContainer.mainContext)))
                .environment(SettingsManager.shared)
                .environment(HealthManager.shared)
        }
    }
}
