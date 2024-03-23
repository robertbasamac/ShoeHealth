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
    
    private var shoeID: UUID
    @Binding private var workouts: [HKWorkout]
    private var updateInterface: () -> Void
    
    @State private var showAddWorkouts: Bool = false
    @State private var selections: Set<UUID> = Set<UUID>()
    @State private var editMode = EditMode.inactive

    @State private var showAssignToShoe: Bool = false
    
    init(shoeID: UUID, workouts: Binding<[HKWorkout]>, updateInterface: @escaping () -> Void) {
        self.shoeID = shoeID
        self._workouts = workouts
        self.updateInterface = updateInterface
    }
    
    var body: some View {
        List(workouts, selection: $selections) { workout in
            WorkoutListItem(workout: workout)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            shoesViewModel.remove(workoutIDs: [workout.id], fromShoe: shoeID)
                            updateInterface()
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
        .toolbarRole(.editor)
        .toolbar {
            toolbarItems()
        }
        .sheet(isPresented: $showAddWorkouts) {
            NavigationStack {
                AddWokoutsToShoeView(shoeID: shoeID) {
                    updateInterface()
                }
                .navigationTitle("Add Workouts")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAssignToShoe) {
            NavigationStack {
                ShoeSelectionView {
                    Text("Select a Shoe to assign the selected Workouts")
                } onDone: { shoeID in
                    withAnimation {
                        shoesViewModel.add(workoutIDs: selections, toShoe: shoeID)
                        updateInterface()
                        
                        selections = Set<UUID>()
                        editMode = .inactive
                    }
                }
                .navigationTitle("Assign Workouts")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - View Components

extension ShoeWorkoutsListView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
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
                        shoesViewModel.remove(workoutIDs: selections, fromShoe: shoeID)
                        updateInterface()
                        
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
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeWorkoutsListView(shoeID: Shoe.previewShoe.id, workouts: .constant([])) { }
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
