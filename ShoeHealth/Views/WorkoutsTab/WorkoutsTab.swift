//
//  WorkoutsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import HealthKit

struct WorkoutsTab: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel: ShoesViewModel
    
    private var healthKitManager = HealthKitManager.shared

    @State private var selectedWorkout: HKWorkout?
    
    var body: some View {
        List {
            ForEach(healthKitManager.workouts, id: \.self) { workout in
                NavigationLink {
                    WorkoutListItem(workout: workout)
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
                ShoeSelectionView { shoeID in
                    shoesViewModel.add(workoutIDs: [workout.id], toShoe: shoeID)
                }
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        })
        .task {
            await healthKitManager.fetchRunningWorkouts()
        }
        .refreshable {
            await healthKitManager.fetchRunningWorkouts()
        }
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        WorkoutsTab()
            .navigationTitle("Workouts")
    }
}
    
