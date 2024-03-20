//
//  ShoeDetailCarouselView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.12.2023.
//

import SwiftUI
import HealthKit

struct ShoeDetailCarouselView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var shoes: [Shoe]
    @State private var selectedShoeID: UUID?
    @State private var workouts: [HKWorkout] = []
    @State private var mostRecentWorkouts: [HKWorkout] = []
    
    @State private var showEditShoe: Bool = false
    @State private var showAllWorkouts: Bool = false
    
    private var selectedID: UUID
    
    @State private var contentHeight: CGFloat = .zero
    @State private var wearColorTint: Color = .white
    
    init(shoes: [Shoe], selectedShoeID: UUID) {
        self._shoes = State(wrappedValue: shoes)
        self.selectedID = selectedShoeID
    }
    
    var body: some View {
        VStack(spacing: 0) {
            shoeCarousel()
            
            workoutsList()
        }
        .background(backgroundGradient, ignoresSafeAreaEdges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        .toolbarTitleMenu {
            toolbarTitleMenu()
        }
        .toolbar {
            toolbarItems()
        }
        .navigationDestination(isPresented: $showAllWorkouts) {
            ShoeWorkoutsListView(shoeID: selectedShoeID ?? UUID(), workouts: $workouts) {
                updateInterface()
            }
        }
        .navigationDestination(isPresented: $showEditShoe) {
            if let shoe = shoesViewModel.getShoe(forID: selectedShoeID ?? UUID()) {
                EditShoeView(shoe: shoe)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if selectedShoeID == nil {
                    selectedShoeID = selectedID
                }
                
                updateInterface()
            }
        }
        .onChange(of: selectedShoeID ?? UUID()) { _, newValue in
            updateInterface()
        }
    }
}

// MARK: - View Components 

extension ShoeDetailCarouselView {
    
    @ViewBuilder
    private func shoeCarousel() -> some View {
        GeometryReader(content: { geometry in
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(shoes) { shoe in
                        VStack(spacing: 0) {
                            VStack(spacing: 0) {
                                Text(shoe.model)
                                    .font(.largeTitle.bold())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.4)
                                    .frame(height: 45)
                                    .padding(.horizontal)
                                
                                Text(shoe.brand)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(height: 25)
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack(spacing: 4) {
                                leftSideStats(of: shoe)
                                
                                ShoeImage(shoe: shoe, width: geometry.size.width)
                                
                                rightSideStats(of: shoe)
                            }
                            .padding(.vertical, 8)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .circular)
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(color: Color(uiColor: .systemGray), radius: 2)
                            }
                            .padding(.vertical, 20)
                        }
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 20)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $selectedShoeID)
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ContentHeightPreferenceKey.self, value: geometry.size.height)
                }
            }
        })
        .onPreferenceChange(ContentHeightPreferenceKey.self) { value in
            contentHeight = value
        }
        .frame(height: contentHeight)
    }
    
    @ViewBuilder
    private func leftSideStats(of shoe: Shoe) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ShoeStatView(label: "CURRENT", value: "\(distanceFormatter.string(fromValue: shoe.currentDistance, unit: .kilometer).uppercased())", color: Color.yellow, alignement: .leading)
            
            ShoeStatView(label: "REMAINING", value: "\(distanceFormatter.string(fromValue: shoe.lifespanDistance - shoe.currentDistance, unit: .kilometer).uppercased())", color: Color.blue, alignement: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func rightSideStats(of shoe: Shoe) -> some View {
        ZStack {
            CircularProgressView(progress: shoe.wearPercentage, lineWidth: 6, color: shoe.wearColor)
            ShoeStatView(label: "WEAR", value: "\(shoe.wearPercentageAsString.uppercased())", color: shoe.wearColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func workoutsList() -> some View {
        List {
            Section {
                HStack {
                    Text("Workouts")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    Text("(\(workouts.count))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        showAllWorkouts.toggle()
                    } label: {
                        Text("Show More")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                
                ForEach(mostRecentWorkouts) { workout in
                    WorkoutListItem(workout: workout)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    shoesViewModel.remove(workoutIDs: [workout.id], fromShoe: selectedShoeID ?? UUID())
                                    updateInterface()
                                }
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .background(Color.black.shadow(.drop(color: Color(uiColor: .systemGray), radius: 2)), in: TopRoundedRectangle(cornerRadius: 25))
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem {
            Button {
                showEditShoe = true
            } label: {
                Text("Edit")
            }
        }
    }
    
    @ViewBuilder
    private func toolbarTitleMenu() -> some View {
        ForEach(shoes) { shoe in
            Button {
                withAnimation(.snappy) {
                    selectedShoeID = shoe.id
                }
            } label: {
                Text(shoe.model)
                Image(systemName: "shoe")
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [wearColorTint.opacity(0.3),
                                                               wearColorTint.opacity(0.15),
                                                               .black,
                                                               .black,
                                                               .black]),
                                   startPoint: .top,
                                   endPoint: .bottom)
    }
}

// MARK: - Helper Methods

extension ShoeDetailCarouselView {
    
    private func updateInterface() {
        guard let selectedShoe = shoes.first(where: { $0.id == selectedShoeID } ) else { return }

        self.workouts = HealthKitManager.shared.getWorkouts(forIDs: selectedShoe.workouts)
        self.mostRecentWorkouts = Array(workouts.prefix(5))
        self.wearColorTint = selectedShoe.wearColor
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailCarouselView(shoes: Shoe.previewShoes, selectedShoeID: Shoe.previewShoes[2].id)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .navigationTitle("Shoes")
        }
    }
}
