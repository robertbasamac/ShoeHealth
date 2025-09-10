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
    
    @State private var activeSheet: ActiveSheet?
    
    @Namespace private var namespace
    
    private enum ActiveSheet: Hashable, Identifiable {
        case addWorkouts
        case assignToShoe
        
        var id: Self { self }
    }
    
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
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: .rect(cornerRadius: Constants.cornerRadius, style: .continuous))
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
        .scrollBounceBehavior(.basedOnSize)
        .overlay {
            emptyWorkoutsView
        }
        .toolbar {
            toolbarItems
        }
        .safeAreaInset(edge: .bottom) {
            actionBottomBar
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addWorkouts:
                NavigationStack {
                    AddWokoutsToShoeView(shoeID: shoe.id)
                }
                .presentationDragIndicator(.visible)

            case .assignToShoe:
                NavigationStack {
                    ShoeSelectionView(
                        selectedShoe: shoesViewModel.getShoe(forID: shoe.id),
                        title: Prompts.SelectShoe.assignWorkoutsTitle,
                        description: Prompts.SelectShoe.assignWorkoutsDescription,
                        systemImage: "shoe.2",
                        onDone: { shoeID in
                            withAnimation {
                                addWorkouts(workoutIDs: Array(selections), to: shoeID)
                                selections = Set<UUID>()
                                editMode = .inactive
                            }
                        }
                    )
                }
                .presentationDragIndicator(.visible)
            }
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
    private var actionBottomBar: some View {
        ActionBottomBar(
            editing: editMode.isEditing,
            selectionsEmpty: selections.isEmpty,
            isShoeRestricted: isShoeRestricted,
            namespace: namespace,
            onAssignToShoe: {
                activeSheet = .assignToShoe
            },
            onDeleteSelected: {
                withAnimation {
                    removeWorkouts(workoutIDs: Array(selections))
                    selections = Set<UUID>()
                    editMode = .inactive
                }
            },
            onAddWorkouts: {
                activeSheet = .addWorkouts
            }
        )
        .padding(.bottom, 10)
        .padding(.horizontal, 40)
    }
    
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
                } else {
                    Text("Select")
                }
            }
            .disabled(shoe.workouts.isEmpty)
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if editMode.isEditing {
                Button {
                    let allWorkoutIDs = Set(groupedWorkouts.flatMap { $0.workouts.map { $0.id } })
                    withAnimation {
                        if selections.count == allWorkoutIDs.count {
                            selections.removeAll()
                        } else {
                            selections = allWorkoutIDs
                        }
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


// MARK: - Reusable Bottom Bar

fileprivate struct ActionBottomBar: View {
    
    let editing: Bool
    let selectionsEmpty: Bool
    let isShoeRestricted: Bool
    let namespace: Namespace.ID
    let onAssignToShoe: () -> Void
    let onDeleteSelected: () -> Void
    let onAddWorkouts: () -> Void

    var body: some View {
        Group {
            if editing {
                HStack(spacing: 40) {
                    Button {
                        onAssignToShoe()
                    } label: {
                        Text("Assign To")
                            .font(.callout)
                            .fontWeight(.medium)
                            .padding(.vertical, 6)
                            .foregroundStyle(selectionsEmpty ? Color(uiColor: .systemGray2) : .accent)
                    }
                    .adaptiveGlassCapsule(tint: selectionsEmpty ? .clear : .accent)
                    .disabled(selectionsEmpty)
                    
                    Button {
                        onDeleteSelected()
                    } label: {
                        Text("Delete")
                            .font(.callout)
                            .fontWeight(.medium)
                            .padding(.vertical, 6)
                            .foregroundStyle(selectionsEmpty ? Color(uiColor: .systemGray2) : .red)
                    }
                    .adaptiveGlassCapsule(tint: selectionsEmpty ? .clear : .red)
                    .disabled(selectionsEmpty)
                }
                .animation(.smooth, value: selectionsEmpty)
            } else {
                Button {
                    onAddWorkouts()
                } label: {
                    Text("Add Workouts")
                        .font(.callout)
                        .fontWeight(.medium)
                        .padding(.vertical, 6)
                        .foregroundStyle(isShoeRestricted ? Color(uiColor: .systemGray2) : .accent)
                }
                .adaptiveGlassCapsule(tint: isShoeRestricted ? .clear : .accent)
                .disabled(isShoeRestricted)
            }
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func adaptiveGlassCapsule(tint: Color) -> some View {
        if #available(iOS 26, *) {
            self
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .tint(tint == .clear ? tint : tint.opacity(0.1))
        } else {
            self
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(tint == .clear ? tint : tint.opacity(0.2))
        }
    }
}
