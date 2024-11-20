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
    private var backButtonSymbol: String
    
    @State private var workouts: [HKWorkout] = []
    @State private var mostRecentWorkouts: [HKWorkout] = []
    
    @State private var showEditShoe: Bool = false
    @State private var showAllWorkouts: Bool = false
    @State private var showAddWorkouts: Bool = false
    
    @State private var opacity: CGFloat = 0
    @State private var navBarVisibility: Visibility = .hidden
    @State private var navBarTitle: String = ""
    
    init(shoe: Shoe, showStats: Bool = true, backButtonSymbol: String = "chevron.left") {
        self.shoe = shoe
        self.backButtonSymbol = backButtonSymbol
    }
    
    var body: some View {
        Group {
            if let imageData = shoe.image {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        StretchyHeaderCell(height: 250, model: shoe.model, brand: shoe.brand, nickname: shoe.nickname, imageData: imageData)
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
                    LazyVStack(spacing: 0) {
                        StaticHeaderCell(model: shoe.model, brand: shoe.brand, nickname: shoe.nickname)
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
        .contentMargins(.bottom, 20)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(navBarTitle)
        .toolbarBackground(navBarVisibility, for: .navigationBar)
        .toolbar {
            toolbarItems
        }
        .navigationDestination(isPresented: $showAllWorkouts) {
            ShoeWorkoutsListView(shoe: shoe, workouts: $workouts, isShoeRestricted: isShoeRestricted())
        }
        .sheet(isPresented: $showEditShoe) {
            NavigationStack {
                ShoeFormView(shoe: shoe)
            }
            .presentationCornerRadius(20)
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showAddWorkouts) {
            NavigationStack {
                AddWokoutsToShoeView(shoeID: shoe.id, workouts: $workouts)
            }
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            self.workouts = healthManager.getWorkouts(forIDs: shoe.workouts)
        }
        .onChange(of: self.workouts) { _, newValue in
            self.mostRecentWorkouts = Array(newValue.prefix(5))
        }
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
    }
    
    @ViewBuilder
    private var lifespanSection: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: settingsManager.unitOfMeasure.symbol, labelFont: .system(size: 14), valueFont: .system(size: 20), color: .blue, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: settingsManager.unitOfMeasure.symbol, labelFont: .system(size: 14), valueFont: .system(size: 20), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
            }
            
            ZStack {
                CircularProgressView(progress: shoe.wearPercentage, lineWidth: 6, color: shoe.wearColor)
                StatCell(label: "WEAR", value: shoe.wearPercentageAsString, labelFont: .system(size: 14), valueFont: .system(size: 20), color: shoe.wearColor)
            }
            .padding(16)
            .frame(width: 140, height: 140)
        }
        .padding(.leading, 20)
        .overlay {
            if shoe.isRetired {
                VStack(spacing: 10) {
                    Image(systemName: "bolt.slash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                    
                    Text("Retired")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.gray)
            }
        }
    }
    
    @ViewBuilder
    private var conditionSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: shoe.wearCondition.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                    
                    Text(shoe.wearCondition.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(shoe.wearColor)
                .frame(width: 70)

                
                VStack(spacing: 10) {
                    Text("\(shoe.wearCondition.description)")
                    Text("\(shoe.wearCondition.action)")
                }
                .font(.callout)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if shoe.wearCondition.rawValue > WearCondition.good.rawValue || shoe.isRetired {
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
            .font(.system(size: 17))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .roundedContainer()
        }
    }
    
    @ViewBuilder
    private var averagesSection: some View {
        VStack(spacing: 8) {
            HStack {
                StatCell(label: "Runs", value: "\(shoe.workouts.count)", color: .gray, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Pace", value: String(format: "%d'%02d\"", shoe.averagePace.minutes, shoe.averagePace.seconds), unit: "/\(settingsManager.unitOfMeasure.symbol)", color: .teal, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Total Distance", value: shoe.totalDistance.as2DecimalsString(), unit: settingsManager.unitOfMeasure.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Distance", value: shoe.averageDistance.as2DecimalsString(), unit: settingsManager.unitOfMeasure.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Total Duration", value: shoe.formattedTotalDuration, color: .yellow, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Duration", value: shoe.formatterAverageDuration, color: .yellow, textAlignment: .leading, containerAlignment: .leading)
            }
        }
    }
    
    @ViewBuilder
    private var personalBestsSection: some View {
        Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 4, content: {
            GridRow {
                Color.clear
                    .gridCellColumns(2)

                Text("PR")
                    .gridCellColumns(3)

                Text("Runs")
                    .gridCellColumns(1)

            }
            .font(.system(size: 17))
            .foregroundStyle(.secondary)
            
            ForEach(RunningCategory.allCases, id: \.self) { category in
                GridRow {
                    Text("\(category.shortTitle)")
                        .font(.system(size: 17))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .gridCellColumns(2)
                    
                    Text(shoe.formattedPersonalBest(for: category))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .gridCellColumns(3)

                    
                    Text("\(shoe.totalRuns[category] ?? 0)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .gridCellColumns(1)
                }
                .font(.system(size: 20, weight: .medium, design: .rounded))
            }
        })
    }
        
    @ViewBuilder
    private var workoutsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("History")
                
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
                .disabled(isShoeRestricted())
            })
            
            VStack(spacing: 4) {
                ForEach(mostRecentWorkouts) { workout in
                    WorkoutListItem(workout: workout)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: backButtonSymbol)
                    .imageScale(.large)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.blurredCircle(Double(1-opacity)))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showEditShoe.toggle()
            } label: {
                Text("Edit")
            }
            .buttonStyle(.blurredCapsule(Double(1-opacity)))
            .disabled(isShoeRestricted())
        }
    }
}

// MARK: - Helpers

extension ShoeDetailView {
    
    private func isShoeRestricted() -> Bool {
        return !storeManager.hasFullAccess && shoesViewModel.shouldRestrictShoe(shoe.id)
    }
    
    private func readFrame(_ frame: CGRect) {
        guard frame.maxY > 0 else {
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
}

// MARK: - Preview

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailView(shoe: Shoe.previewShoe)
                .environmentObject(NavigationRouter())
                .environmentObject(StoreManager())
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .environment(SettingsManager.shared)
                .environment(HealthManager.shared)
        }
    }
}
