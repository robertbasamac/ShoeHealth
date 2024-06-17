//
//  ShoeWorkoutsListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.01.2024.
//

import SwiftUI
import HealthKit
import SwiftData

struct ShoeWorkoutsListView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @Query var shoes: [Shoe]
    
    @State private var workouts: [HKWorkout] = []
    
    @State private var showAddWorkouts: Bool = false
    @State private var selections: Set<UUID> = Set<UUID>()
    @State private var editMode = EditMode.inactive

    @State private var showAssignToShoe: Bool = false
    
    init(shoeID: UUID) {
        self._shoes = Query(filter: #Predicate { $0.id == shoeID })
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
                            if let shoe = shoes.first {
                                shoesViewModel.remove(workoutIDs: [workout.id], fromShoe: shoe.id)
                                workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
                            }
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
                if let shoe = shoes.first {
                    AddWokoutsToShoeView(shoeID: shoe.id) {
                        workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
                    }
                    .navigationTitle("Add Workouts")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAssignToShoe) {
            NavigationStack {
                ShoeSelectionView(selectedShoe: shoesViewModel.getShoe(ofWorkoutID: selections.first ?? UUID()),
                                  title: Prompts.SelectShoe.assignWorkoutsTitle,
                                  description: Prompts.SelectShoe.assignWorkoutsDescription,
                                  systemImage: "shoe.2",
                                  onDone: { shoeID in
                    withAnimation {
                        shoesViewModel.add(workoutIDs: selections, toShoe: shoeID)
                        
                        if let shoe = shoes.first {
                            workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
                        }
                        
                        selections = Set<UUID>()
                        editMode = .inactive
                    }
                })
            }
            .presentationDragIndicator(.visible)
        }
        .onAppear(perform: {
            if let shoe = shoes.first {
                self.workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
            }
        })
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
                        if let shoe = shoes.first {
                            shoesViewModel.remove(workoutIDs: selections, fromShoe: shoe.id)
                            self.workouts = HealthManager.shared.getWorkouts(forIDs: shoe.workouts)
                        }
                        
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
            ShoeWorkoutsListView(shoeID: Shoe.previewShoe.id)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
