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

    @State private var workouts: [HKWorkout] = []
    private var shoeID: UUID
    private var onAdd: () -> Void
    
    init(shoeID: UUID, onAdd: @escaping () -> Void) {
        self.shoeID = shoeID
        self.onAdd = onAdd
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
            workouts = getUnusedWorkouts()
            editMode = .active
        })
    }
}

extension AddWokoutsToShoeView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                shoesViewModel.add(workoutIDs: selections, toShoe: shoeID)
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
    
    private func getUnusedWorkouts() -> [HKWorkout] {
        let allWorkoutsIDs: Set<UUID> = Set(shoesViewModel.shoes.flatMap { $0.workouts } )
        
        return HealthKitManager.shared.workouts.filter { !allWorkoutsIDs.contains($0.id) }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        AddWokoutsToShoeView(shoeID: Shoe.previewShoe.id) { }
            .navigationTitle("Add Workouts")
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
    }
}
