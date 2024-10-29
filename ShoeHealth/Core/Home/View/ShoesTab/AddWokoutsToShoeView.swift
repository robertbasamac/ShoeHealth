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
    @Environment(HealthManager.self) private var healthManager
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
        .navigationTitle("Add Workouts")
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .environment(\.editMode, $editMode)
        .overlay {
            emptyWorkoutsView
        }
        .toolbar {
            toolbarItems
        }
        .onAppear {
            getAvailableWorkous()
            editMode = .active
        }
    }
}

extension AddWokoutsToShoeView {
    
    @ViewBuilder
    private var emptyWorkoutsView: some View {
        if availableWorkouts.isEmpty {
            ContentUnavailableView {
                Label("No Workouts Available", systemImage: "figure.run.circle")
            } description: {
                Text("There are currently no unassigned running workouts available in your Apple Health data.")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {        
        if editMode.isEditing && !availableWorkouts.isEmpty {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if selections.count == availableWorkouts.count {
                        selections = Set<UUID>()
                    } else {
                        selections = Set(availableWorkouts.map { $0.id })
                    }
                } label: {
                    if selections.count == availableWorkouts.count {
                        Text("Deselect All")
                    } else {
                        Text("Select All")
                    }
                }
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task {
                    await shoesViewModel.add(workoutIDs: Array(selections), toShoe: shoeID)
                }
                self.workouts.append(contentsOf: healthManager.getWorkouts(forIDs: Array(selections)))
                self.workouts.sort { $0.endDate > $1.endDate }
                
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
        self.availableWorkouts = healthManager.workouts.filter { !allWorkoutsIDs.contains($0.id) }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var workouts: [HKWorkout] = []
    
    NavigationStack {
        AddWokoutsToShoeView(shoeID: Shoe.previewShoe.id, workouts: $workouts)
            .navigationTitle("Add Workouts")
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
            .environment(HealthManager.shared)
    }
}
