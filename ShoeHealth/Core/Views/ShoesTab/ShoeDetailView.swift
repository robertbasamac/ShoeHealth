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
                    LazyVStack(spacing: 0) {
                        StretchyHeaderCell(height: 250, title: shoe.model, subtitle: shoe.brand, imageData: imageData)
                            .overlay(content: {
                                Color.black
                                    .opacity(Double(opacity))
                            })
                            .readingFrame { frame in
                                readFrame(frame)
                            }
                        
                        workoutsSection
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.stretchyHeader)
                .contentMargins(.top, 44)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        StaticHeaderCell(title: shoe.model, subtitle: shoe.brand)
                            .frame(height: 75)
                            .overlay(content: {
                                Color.black
                                    .opacity(Double(opacity))
                            })
                            .readingFrame { frame in
                                readFrame(frame)
                            }
                        
                        workoutsSection
                    }
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
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .opacity(opacity)
                .padding(.horizontal, 90)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private var workoutsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Workouts")
                    .font(.title2)
                    .fontWeight(.bold)
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .font(.title2)
            .fontWeight(.bold)
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
        .padding(20)
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
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
