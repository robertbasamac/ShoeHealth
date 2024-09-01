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
    
    private var shoeID: UUID
    @Binding private var workouts: [HKWorkout]
    
    @State private var availableWorkouts: [HKWorkout] = []
    @State private var selections: Set<UUID> = Set<UUID>()
    @State private var editMode = EditMode.active
    
    init(shoeID: UUID, workouts: Binding<[HKWorkout]>) {
        self.shoeID = shoeID
        self._workouts = workouts
    }
    
    var body: some View {
        List(availableWorkouts, selection: $selections) { workout in
            WorkoutListItem(workout: workout)
        }
        .environment(\.editMode, $editMode)
        .toolbar {
            toolbarItems()
        }
        .onAppear {
            getAvailableWorkous()
            editMode = .active
        }
    }
}

extension AddWokoutsToShoeView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                shoesViewModel.add(workoutIDs: Array(selections), toShoe: shoeID)
                self.workouts.append(contentsOf: HealthManager.shared.getWorkouts(forIDs: Array(selections)))
                
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
    
    private func getAvailableWorkous() {
        let allWorkoutsIDs: Set<UUID> = Set(shoesViewModel.shoes.flatMap { $0.workouts } )
        self.availableWorkouts = HealthManager.shared.workouts.filter { !allWorkoutsIDs.contains($0.id) }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        AddWokoutsToShoeView(shoeID: Shoe.previewShoe.id, workouts: .constant([]))
            .navigationTitle("Add Workouts")
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
    }
}
