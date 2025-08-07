//
//  ShoeWorkoutsListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.01.2024.
//

import SwiftUI

struct ShoeWorkoutsListView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    
    @State private var shoe: Shoe
    private var isShoeRestricted: Bool
    
    @State private var groupedWorkouts: [WorkoutGroup] = []
    
    @State private var selections: Set<UUID> = Set<UUID>()
    @State private var editMode = EditMode.inactive
    
    @State private var showAddWorkouts: Bool = false
    @State private var showAssignToShoe: Bool = false
    
    init(shoe: Shoe, isShoeRestricted: Bool = false) {
        self.shoe = shoe
        self.isShoeRestricted = isShoeRestricted
    }
    
    var body: some View {
        List(selection: $selections) {
            ForEach(groupedWorkouts) { group in
                Section {
                    ForEach(group.workouts) { workout in
                        WorkoutListItem(workout: workout)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: .rect(cornerRadius: 10, style: .continuous))
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
                } header: {
                    Text(group.title)
                        .headerProminence(.increased)
                }
                .listSectionSeparator(.hidden)
            }
        }
        .listStyle(.grouped)
        .listSectionSpacing(.custom(4))
        .environment(\.editMode, $editMode)
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(editMode.isEditing)
        .hideTabBar()
        .overlay {
            emptyWorkoutsView
        }
        .toolbar {
            toolbarItems
        }
        .sheet(isPresented: $showAddWorkouts) {
            NavigationStack {
                AddWokoutsToShoeView(shoeID: shoe.id)
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
        .onAppear {
            groupedWorkouts = WorkoutGroup.groupWorkoutsByMonthAndYear(workouts: healthManager.getWorkouts(forIDs: shoe.workouts))
        }
        .onChange(of: shoe.workouts) { _, _ in
            groupedWorkouts = WorkoutGroup.groupWorkoutsByMonthAndYear(workouts: healthManager.getWorkouts(forIDs: shoe.workouts))
        }
    }
}

// MARK: - View Components

extension ShoeWorkoutsListView {
    
    @ViewBuilder
    private var emptyWorkoutsView: some View {
        if shoe.workouts.isEmpty {
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
            .disabled(shoe.workouts.isEmpty)
        }
        
        if editMode.isEditing {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    let allWorkoutIDs = groupedWorkouts.flatMap { $0.workouts.map { $0.id } }

                    if selections.count == allWorkoutIDs.count {
                        selections = Set<UUID>()
                    } else {
                        selections = Set(allWorkoutIDs)
                    }
                } label: {
                    if selections.count == groupedWorkouts.flatMap({ $0.workouts }).count {
                        Text("Deselect All")
                    } else {
                        Text("Select All")
                    }
                }
            }
        }
        
        ToolbarItemGroup(placement: .status) {
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
    }
    
    private func addWorkouts(workoutIDs: [UUID], to shoeID: UUID) {
        Task {
            await shoesViewModel.add(workoutIDs: workoutIDs, toShoe: shoeID)
        }
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeWorkoutsListView(shoe: Shoe.previewShoe)
                .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.container.mainContext)))
                .environment(HealthManager.shared)
        }
    }
}


// MARK: - View Extension

fileprivate extension View {
    
    @ViewBuilder
    func hideTabBar() -> some View {
        if #available(iOS 18, *) {
            self.toolbarVisibility(.hidden, for: .tabBar)
        } else {
            self.toolbar(.hidden, for: .tabBar)
        }
    }
}

