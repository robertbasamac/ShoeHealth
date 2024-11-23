//
//  WorkoutsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import HealthKit

struct WorkoutsTab: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    
    @State private var selectedWorkout: HKWorkout?
    
    var body: some View {
        List {
            ForEach(healthManager.workouts, id: \.self) { workout in
                HStack(spacing: 2) {
                    WorkoutListItem(workout: workout)
                    if let shoe = shoesViewModel.getShoe(ofWorkoutID: workout.id) {
                        ShoeImage(imageData: shoe.image, width: 64)
                            .frame(width: 64, height: 64)
                            .clipShape(.rect(cornerRadius: 10))
                            .onTapGesture {
                                navigationRouter.navigate(to: .shoe(shoe))
                            }
                    }
                }
                .frame(height: 64)
                .padding(.leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        selectedWorkout = workout
                    } label: {
                        Label("Add Shoe", systemImage: "shoe")
                    }
                    .tint(.gray)
                }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(4)
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .overlay {
            emptyWorkoutsView
        }
        .navigationDestination(for: Shoe.self, destination: { shoe in
            ShoeDetailView(shoe: shoe)
        })
        .sheet(item: $selectedWorkout, content: { workout in
            NavigationStack {
                ShoeSelectionView(selectedShoe: shoesViewModel.getShoe(ofWorkoutID: workout.id),
                                  title: Prompts.SelectShoe.selectWorkoutShoeTitle,
                                  description: Prompts.SelectShoe.selectWorkoutShoeDescription,
                                  systemImage: "shoe.2",
                                  onDone: { shoeID in
                    Task {
                        await shoesViewModel.add(workoutIDs: [workout.id], toShoe: shoeID)
                    }
                })
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        })
        .refreshable {
            await healthManager.fetchRunningWorkouts()
        }
    }
}

// MARK: - View Components

extension WorkoutsTab {
    
    @ViewBuilder
    private var emptyWorkoutsView: some View {
        if healthManager.workouts.isEmpty {
            ContentUnavailableView {
                Label("No Workouts Available", systemImage: "figure.run.circle")
            } description: {
                Text("There are no running workouts available in your Apple Health data.")
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        WorkoutsTab()
            .navigationTitle("Workouts")
            .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
            .environment(HealthManager.shared)
    }
}
