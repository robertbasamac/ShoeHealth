//
//  WorkoutsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import HealthKit

struct WorkoutsTab: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    
    @State private var selectedWorkout: HKWorkout?
    
    var body: some View {
        List {
            ForEach(healthManager.workouts, id: \.self) { workout in
                NavigationLink {
                    SampleView(workout: workout)
                } label: {
                    WorkoutListItem(workout: workout)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        selectedWorkout = workout
                    } label: {
                        Label("Add Shoe", systemImage: "shoe")
                    }
                    .tint(.orange)
                }
            }
        }
        .sheet(item: $selectedWorkout, content: { workout in
            NavigationStack {
                ShoeSelectionView(selectedShoe: shoesViewModel.getShoe(ofWorkoutID: workout.id),
                                  title: Prompts.SelectShoe.assignWorkoutsDescription,
                                  description: Prompts.SelectShoe.assignWorkoutsDescription,
                                  systemImage: "shoe.2",
                                  onDone: { shoeID in
                    Task {
                        await shoesViewModel.add(workoutIDs: [workout.id], toShoe: shoeID)
                    }
                })
            }
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        })
        .refreshable {
            await healthManager.fetchRunningWorkouts()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        WorkoutsTab()
            .navigationTitle("Workouts")
            .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext, storeManager: StoreManager()))
    }
}
    
