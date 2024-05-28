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
    
    @State private var workouts: [HKWorkout] = []
    @State private var mostRecentWorkouts: [HKWorkout] = []
    
    @State private var showEditShoe: Bool = false
    @State private var showAllWorkouts: Bool = false

    @State private var opacity: CGFloat = 0
    @State private var headerOpacity: CGFloat = 0
        
    init(shoe: Shoe) {
        self.shoe = shoe
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            header
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(2)
            
            if let imageData = shoe.image {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 20) {
                        StretchyHeaderCell(height: 250, title: shoe.model, subtitle: shoe.brand, imageData: imageData)
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
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.stretchyHeader)
                .contentMargins(.top, 44)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 20) {
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
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.staticHeader)
                .contentMargins(.top, 44)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showEditShoe) {
            EditShoeView(shoe: shoe)
        }
        .navigationDestination(isPresented: $showAllWorkouts) {
            ShoeWorkoutsListView(shoeID: shoe.id, workouts: $workouts) {
                updateInterface()
            }
        }
        .onAppear(perform: {
            updateInterface()
        })
    }
}

// MARK: - View Components

extension ShoeDetailView {
    
    @ViewBuilder
    private var header: some View {
        HStack(spacing: 8) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .asHeaderImageButton()
                    .background(.bar.opacity(Double(1 - opacity)), in: .circle)
            }
            
            Spacer(minLength: 0)

            Button {
                showEditShoe.toggle()
            } label: {
                Text("Edit")
                    .asHeaderTextButton()
                    .background(.bar.opacity(Double(1 - opacity)), in: .capsule(style: .circular))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar.opacity(headerOpacity))
        .overlay(alignment: .bottom, content: {
            Divider()
                .opacity(headerOpacity)
        })
        .overlay {
            Text(shoe.model)
                .font(.system(size: 17))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .opacity(opacity)
                .padding(.horizontal, 90)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private var lifespanSection: some View {
        VStack(spacing: 8) {
            Text("Health")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: UnitLength.kilometers.symbol, labelFont: .system(size: 14), valueFont: .system(size: 20), color: .blue, textAlignment: .leading, containerAlignment: .leading)
                    StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: UnitLength.kilometers.symbol, labelFont: .system(size: 14), valueFont: .system(size: 20), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
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
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var statsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Statistics")
            }
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            
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
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var averagesSection: some View {
        VStack(spacing: 8) {
            HStack {
                StatCell(label: "Runs", value: "\(shoe.workouts.count)", color: .gray, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Pace", value: String(format: "%d'%02d\"", shoe.averagePace.minutes, shoe.averagePace.seconds), unit: "/KM", color: .teal, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Total Distance", value: shoe.totalDistance.as2DecimalsString(), unit: UnitLength.kilometers.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Distance", value: shoe.averageDistance.as2DecimalsString(), unit: UnitLength.kilometers.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
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
                Text("PR")
                Text("Runs")
            }
            .font(.system(size: 17))
            .foregroundStyle(.secondary)
            
            ForEach(RunningCategory.allCases, id: \.self) { category in
                GridRow {
                    Text("\(category.shortTitle)")
                        .font(.system(size: 17))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(shoe.formattedPersonalBest(for: category))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("\(shoe.totalRuns[category] ?? 0)")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .font(.system(size: 20, weight: .medium, design: .rounded))
            }
        })
    }
        
    @ViewBuilder
    private var workoutsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("History")
                
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .onTapGesture {
                showAllWorkouts.toggle()
            }
            
            VStack(spacing: 4) {
                ForEach(mostRecentWorkouts) { workout in
                    WorkoutListItem(workout: workout)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Helpers

extension ShoeDetailView {
    
    private func readFrame(_ frame: CGRect) {
        let topPadding = UIApplication.topSafeAreaInsets + 44
        
        opacity = interpolateOpacity(position: frame.maxY, minPosition: topPadding + 30, maxPosition: topPadding + 75, reversed: true)
        headerOpacity = interpolateOpacity(position: frame.maxY, minPosition: topPadding, maxPosition: topPadding + 4, reversed: true)
    }
    
    private func updateInterface() {
        self.workouts = HealthKitManager.shared.getWorkouts(forIDs: shoe.workouts)
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
