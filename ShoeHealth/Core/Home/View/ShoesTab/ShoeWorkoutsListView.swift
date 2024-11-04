//
//  ShoeWorkoutsListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.01.2024.
//

import SwiftUI
import HealthKit

struct ShoeWorkoutsListView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    private var shoe: Shoe
    private var isShoeRestricted: Bool
    @Binding private var workouts: [HKWorkout]
    
    @State private var selections: Set<UUID> = Set<UUID>()
    @State private var editMode = EditMode.inactive
    
    @State private var showAddWorkouts: Bool = false
    @State private var showAssignToShoe: Bool = false
    
    init(shoe: Shoe, workouts: Binding<[HKWorkout]>, isShoeRestricted: Bool = false) {
        self.shoe = shoe
        self.isShoeRestricted = isShoeRestricted
        self._workouts = workouts
    }
    
    var body: some View {
        List(workouts, selection: $selections) { workout in
            WorkoutListItem(workout: workout)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            removeWorkouts(workoutIDs: [workout.id])
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(editMode.isEditing)
        .scrollBounceBehavior(.basedOnSize)
        .overlay {
            emptyWorkoutsView
        }
        .toolbar {
            toolbarItems
        }
        .sheet(isPresented: $showAddWorkouts) {
            NavigationStack {
                AddWokoutsToShoeView(shoeID: shoe.id, workouts: $workouts)
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAssignToShoe) {
            NavigationStack {
                ShoeSelectionView(selectedShoe: shoesViewModel.getShoe(forID: shoe.id),
                                  title: Prompts.SelectShoe.assignWorkoutsTitle,
                                  description: Prompts.SelectShoe.assignWorkoutsDescription,
                                  systemImage: "shoe.2",
                                  onDone: { shoeID in
                    withAnimation {
                        addWorkouts(workoutIDs: Array(selections), to: shoeID)
                        
                        selections = Set<UUID>()
                        editMode = .inactive
                    }
                })
            }
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - View Components

extension ShoeWorkoutsListView {
    
    @ViewBuilder
    private var emptyWorkoutsView: some View {
        if workouts.isEmpty {
            ContentUnavailableView {
                Label("No Workouts", systemImage: "figure.run.circle")
            } description: {
                Text("There are currently no running workouts assigned to this Shoe pair. Use the \"Add Workouts\" button to add some.")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation {
                    editMode = editMode.isEditing ? .inactive : .active
                }
            } label: {
                if editMode.isEditing {
                    Text("Cancel")
                        .fontWeight(.bold)
                } else {
                    Text("Select")
                }
            }
            .animation(.none, value: editMode)
            .disabled(workouts.isEmpty)
        }
        
        if editMode.isEditing {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if selections.count == workouts.count {
                        selections = Set<UUID>()
                    } else {
                        selections = Set(workouts.map { $0.id })
                    }
                } label: {
                    if selections.count == workouts.count {
                        Text("Deselect All")
                    } else {
                        Text("Select All")
                    }
                }
            }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            if editMode.isEditing {
                Button {
                    showAssignToShoe.toggle()
                } label: {
                    Text("Assign To")
                }
                .disabled(selections.isEmpty)
                
                Button {
                    withAnimation {
                        removeWorkouts(workoutIDs: Array(selections))
                        
                        selections = Set<UUID>()
                        editMode = .inactive
                    }
                } label: {
                    Text("Delete")
                }
                .disabled(selections.isEmpty)
            } else {
                Button {
                    showAddWorkouts.toggle()
                } label: {
                    Text("Add Workouts")
                }
                .disabled(isShoeRestricted)
            }
        }
    }
}

// MARK: - Helper Methods

extension ShoeWorkoutsListView {
    
    private func removeWorkouts(workoutIDs: [UUID]) {
        Task {
            await shoesViewModel.remove(workoutIDs: workoutIDs, fromShoe: shoe.id)
        }
        
        self.workouts = self.workouts.filter { workout in
            !workoutIDs.contains(workout.id)
        }
    }
    
    private func addWorkouts(workoutIDs: [UUID], to shoeID: UUID) {
        Task {
            await shoesViewModel.add(workoutIDs: workoutIDs, toShoe: shoeID)
        }
        
        self.workouts = self.workouts.filter { workout in
            !selections.contains(workout.id)
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var workouts: [HKWorkout] = []
    
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeWorkoutsListView(shoe: Shoe.previewShoe, workouts: $workouts)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
