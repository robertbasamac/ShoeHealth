//
//  AddWokoutsToShoeView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 28.01.2024.
//

import SwiftUI
import HealthKit

struct AddWokoutsToShoeView: View {

    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var healthKitManager = HealthKitManager.shared
    
    @State private var selections: Set<UUID> = Set<UUID>()
    @State private var editMode = EditMode.inactive

    private var workouts: [HKWorkout] = []
    private var shoeID: UUID
    private var onAdd: () -> Void
    
    init(shoeID: UUID, workouts: [HKWorkout], onAdd: @escaping () -> Void) {
        self.shoeID = shoeID
        self.onAdd = onAdd
        self.workouts = filteredWorkouts(workouts)
    }
    
    var body: some View {
        List(workouts, selection: $selections) { workout in
            WorkoutListItem(workout: workout)
        }
        .environment(\.editMode, $editMode)
        .toolbar {
            toolbarItems()
        }
        .onAppear(perform: {
            editMode = .active
        })
    }
}

extension AddWokoutsToShoeView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                shoesViewModel.add(workouts: selections, toShoe: shoeID)
                onAdd()
                dismiss()
            } label: {
                Text("Add")
            }
            .disabled(selections.isEmpty)
        }
    }
}

// MARK: - Helper Methods

extension AddWokoutsToShoeView {
    
    private func filteredWorkouts(_ workouts: [HKWorkout]) -> [HKWorkout] {
        return healthKitManager.workouts.filter { workout in
            !workouts.contains { workoutToRemove in
                workout.uuid == workoutToRemove.id
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        AddWokoutsToShoeView(shoeID: Shoe.previewShoe.id, workouts: []) { }
            .navigationTitle("Add Workouts")
    }
}
