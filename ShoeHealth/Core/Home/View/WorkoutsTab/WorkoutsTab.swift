//
//  WorkoutsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import HealthKit

struct WorkoutsTab: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    
    @State private var groupedWorkouts: [WorkoutGroup] = []
    @State private var selectedWorkout: HKWorkout?
    @State private var selections: Set<UUID> = []
    @State private var editMode: EditMode = .inactive
    @State private var isPresentingBulkAssign: Bool = false
    
    @ScaledMetric(relativeTo: .largeTitle) var size: CGFloat = 64
    
    var body: some View {
        List(selection: $selections) {
            groupedWorkoutSections
        }
        .listStyle(.plain)
        .listSectionSpacing(.custom(4))
        .environment(\.editMode, $editMode)
        .toolbar {
            toolbarItems
        }
        .navigationTitle("Workouts")
        .overlay {
            emptyWorkoutsView
        }
        .navigationDestination(for: Shoe.self, destination: { shoe in
            ShoeDetailView(shoe: shoe)
        })
        .sheet(item: $selectedWorkout, content: { workout in
            NavigationStack {
                ShoeSelectionView(selectedShoe: shoesViewModel.getShoe(ofWorkoutID: workout.id),
                                  title: Prompts.SelectShoe.selectWorkoutShoeTitle,
                                  description: Prompts.SelectShoe.selectWorkoutShoeDescription,
                                  systemImage: "shoe.2",
                                  onDone: { shoeID in
                    Task {
                        await shoesViewModel.add(workoutIDs: [workout.id], toShoe: shoeID)
                    }
                })
            }
            .presentationCornerRadius(Constants.presentationCornerRadius)
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $isPresentingBulkAssign) {
            NavigationStack {
                ShoeSelectionView(selectedShoe: nil,
                                  title: Prompts.SelectShoe.selectWorkoutShoeTitle,
                                  description: Prompts.SelectShoe.selectWorkoutShoeDescription,
                                  systemImage: "shoe.2",
                                  onDone: { shoeID in
                    Task {
                        await shoesViewModel.add(workoutIDs: Array(selections), toShoe: shoeID)
                        selections.removeAll()
                        editMode = .inactive
                    }
                })
            }
            .presentationCornerRadius(Constants.presentationCornerRadius)
            .presentationDragIndicator(.visible)
        }
        .refreshable {
            await healthManager.fetchRunningWorkouts()
        }
        .onAppear {
            groupedWorkouts = WorkoutGroup.groupWorkoutsByMonthAndYear(workouts: healthManager.workouts)
            selections.removeAll()
            editMode = .inactive
        }
        .onChange(of: healthManager.workouts) { _, newValue in
            groupedWorkouts = WorkoutGroup.groupWorkoutsByMonthAndYear(workouts: newValue)
        }
    }
}

// MARK: - View Components

extension WorkoutsTab {
    
    @ViewBuilder
    private var groupedWorkoutSections: some View {
        ForEach(groupedWorkouts) { group in
            Section {
                ForEach(group.workouts) { workout in
                    workoutRow(for: workout)
                }
            } header: {
                Text(group.title)
                    .headerProminence(.increased)
            }
            .listSectionSeparator(.hidden)
        }
    }
    
    @ViewBuilder
    private func workoutRow(for workout: HKWorkout) -> some View {
        HStack(spacing: 2) {
            WorkoutListItem(workout: workout)
            
            if !editMode.isEditing {
                if let shoe = shoesViewModel.getShoe(ofWorkoutID: workout.id) {
                    HStack {
                        Text(shoe.nickname)
                            .font(.headline)
                            .italic()
                            .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xLarge)
                            .foregroundStyle(Color.theme.accent)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        
                        ShoeImage(imageData: shoe.image, showBackground: false, width: 64)
                            .frame(width: size, height: size)
                            .clipShape(.rect(cornerRadius: Constants.cornerRadius))
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        navigationRouter.navigate(to: .shoe(shoe))
                    }
                } else {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.light)
                        .foregroundStyle(Color.theme.accent)
                        .padding(size / 3)
                        .frame(width: size, height: size)
                        .contentShape(.rect)
                        .onTapGesture {
                            selectedWorkout = workout
                        }
                }
            }
        }
        .frame(height: size)
        .padding(.leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: .rect(cornerRadius: Constants.cornerRadius, style: .continuous))
        .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .tag(workout.id)
    }
    
    @ViewBuilder
    private var emptyWorkoutsView: some View {
        if healthManager.workouts.isEmpty {
            ContentUnavailableView {
                Label("No Workouts Available", systemImage: "figure.run.circle")

            } description: {
                Text("There are no running workouts available in your Apple Health data.")

            } actions: {
                Button {
                    Task {
                        await healthManager.fetchRunningWorkouts()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .foregroundStyle(.black)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if !healthManager.workouts.isEmpty {
                Button {
                    withAnimation {
                        if editMode.isEditing {
                            selections.removeAll()
                            editMode = .inactive
                        } else {
                            editMode = .active
                        }
                    }
                } label: {
                    if editMode.isEditing {
                        Text("Cancel")
                    } else {
                        Text("Select")
                    }
                }
                
                if editMode.isEditing {
                    Button {
                        withAnimation {
                            selections.removeAll()
                            editMode = .inactive
                        }
                    } label: {
                        Text("Cancel")
                    }
                } else {
                    Button {
                        withAnimation {
                            editMode = .active
                        }
                    } label: {
                        Text("Select")
                    }
                }
            }
        }
        
        if #available(iOS 26, *) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            if editMode.isEditing {
                Button {
                    isPresentingBulkAssign = true
                } label: {
                    Text("Assign")
                }
                .disabled(selections.isEmpty)
            }
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

// MARK: - Previews

#Preview {
    NavigationStack {
        WorkoutsTab()
            .navigationTitle("Workouts")
            .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.emptyContainer.mainContext)))
            .environment(HealthManager.shared)
    }
}

