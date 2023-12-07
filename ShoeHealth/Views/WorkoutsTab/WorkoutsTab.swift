//
//  WorkoutsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import HealthKit

struct WorkoutsTab: View {
    @State var healthKitManager = HealthKitManager.shared

    @State private var selectedWorkout: HKWorkout?
    
    var body: some View {
        List {
            ForEach(healthKitManager.workouts, id: \.self) { workout in
                NavigationLink {
                    WorkoutListItem(workout: workout)
                } label: {
                    WorkoutListItem(workout: workout)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
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
                ShoeSelectionView(workout: workout)
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        })
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
    
