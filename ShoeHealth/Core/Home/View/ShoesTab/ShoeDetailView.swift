//
//  ShoeDetailView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.04.2024.
//

import SwiftUI
import HealthKit

struct ShoeDetailView: View {
       
    @Environment(\.dismiss) private var dismiss
    
    private var shoe: Shoe
    private var backButtonSymbol: String
    
    @State private var workouts: [HKWorkout] = []
    @State private var mostRecentWorkouts: [HKWorkout] = []
    
    @State private var showEditShoe: Bool = false
    @State private var showAllWorkouts: Bool = false

    @State private var opacity: CGFloat = 0
    @State private var navBarVisibility: Visibility = .hidden
    @State private var navBarTitle: String = ""
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    init(shoe: Shoe, showStats: Bool = true, backButtonSymbol: String = "chevron.left") {
        self.shoe = shoe
        self.backButtonSymbol = backButtonSymbol
    }
    
    var body: some View {
        Group {
            if let imageData = shoe.image {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 12) {
                        StretchyHeaderCell(height: 250, title: shoe.model, subtitle: shoe.brand, imageData: imageData)
                            .overlay(content: {
                                Color(uiColor: .systemBackground)
                                    .opacity(Double(opacity))
                            })
                            .readingFrame { frame in
                                readFrame(frame)
                            }
                        
                        lifespanSection
                        statsSection
                        workoutsSection
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.stretchyHeader)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 12) {
                        StaticHeaderCell(title: shoe.model, subtitle: shoe.brand)
                            .frame(height: 75)
                            .overlay(content: {
                                Color.black
                                    .opacity(Double(opacity))
                            })
                            .readingFrame { frame in
                                readFrame(frame)
                            }
                        
                        lifespanSection
                        statsSection
                        workoutsSection
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.staticHeader)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(navBarTitle)
        .toolbarBackground(navBarVisibility, for: .navigationBar)
        .toolbar {
            toolbarItems
        }
        .navigationDestination(isPresented: $showAllWorkouts) {
            ShoeWorkoutsListView(shoeID: shoe.id, workouts: $workouts) {
                updateInterface()
            }
        }
        .sheet(isPresented: $showEditShoe) {
            NavigationStack {
                EditShoeView(shoe: shoe)
            }
            .presentationCornerRadius(20)
            .interactiveDismissDisabled()
        }
        .onAppear {
            updateInterface()
        }
        .onChange(of: unitOfMeasureString) { _, newValue in
            unitOfMeasure = UnitOfMeasure(rawValue: newValue) ?? .metric
        }
    }
}

// MARK: - View Components

extension ShoeDetailView {
    
    @ViewBuilder
    private var lifespanSection: some View {
        VStack(spacing: 0) {
            Text("Health")
                .asHeader()
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: unitOfMeasure.symbol, labelFont: .system(size: 14), valueFont: .system(size: 20), color: .blue, textAlignment: .leading, containerAlignment: .leading)
                    StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: unitOfMeasure.symbol, labelFont: .system(size: 14), valueFont: .system(size: 20), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
                }
                
                ZStack {
                    CircularProgressView(progress: shoe.wearPercentage, lineWidth: 6, color: shoe.wearColor)
                        .padding()
                    StatCell(label: "WEAR", value: shoe.wearPercentageAsString, labelFont: .system(size: 14), valueFont: .system(size: 20), color: shoe.wearColor)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: 20)
            }
            .padding(.horizontal, 20)
            .frame(height: 140)
            .roundedContainer()
        }
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
                StatCell(label: "Avg Pace", value: String(format: "%d'%02d\"", shoe.averagePace.minutes, shoe.averagePace.seconds), unit: "/\(unitOfMeasure.symbol)", color: .teal, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Total Distance", value: shoe.totalDistance.as2DecimalsString(), unit: unitOfMeasure.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Distance", value: shoe.averageDistance.as2DecimalsString(), unit: unitOfMeasure.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
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
            
            VStack(spacing: 4) {
                ForEach(mostRecentWorkouts) { workout in
                    WorkoutListItem(workout: workout)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
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
        }
    }
}

// MARK: - Helpers

extension ShoeDetailView {
    
    private func readFrame(_ frame: CGRect) {
        guard frame.maxY > 0 else {
            return
        }
        
        let topPadding: CGFloat = UIApplication.statusBarHeight + 44
        let showNavBarTitlePadding: CGFloat = 25
        
        opacity = interpolateOpacity(position: frame.maxY,
                                     minPosition: topPadding + showNavBarTitlePadding,
                                     maxPosition: topPadding + 75,
                                     reversed: true)
        
        navBarVisibility = frame.maxY < (topPadding - 0.5) ? .automatic : .hidden
        navBarTitle = frame.maxY < (topPadding + showNavBarTitlePadding) ? shoe.model : ""
    }
    
    @MainActor
    private func updateInterface() {
        self.workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
        self.mostRecentWorkouts = Array(workouts.prefix(5))
    }
}

// MARK: - Preview

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailView(shoe: Shoe.previewShoe)
        }
    }
}
