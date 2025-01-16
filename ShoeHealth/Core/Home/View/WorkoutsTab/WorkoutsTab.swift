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
    
    @ScaledMetric(relativeTo: .largeTitle) var size: CGFloat = 64
    
    var body: some View {
        List {
            ForEach(groupedWorkouts) { group in
                Section {
                    ForEach(group.workouts) { workout in
                        HStack(spacing: 2) {
                            WorkoutListItem(workout: workout)
                            
                            if let shoe = shoesViewModel.getShoe(ofWorkoutID: workout.id) {
                                HStack {
                                    Text(shoe.nickname)
                                        .font(.headline)
                                        .italic()
                                        .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xLarge)
                                        .foregroundStyle(Color.theme.accent)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                    
                                    ShoeImage(imageData: shoe.image, width: 64)
                                        .frame(width: size, height: size)
                                        .clipShape(.rect(cornerRadius: 10))
                                        .onTapGesture {
                                            navigationRouter.navigate(to: .shoe(shoe))
                                        }
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
                        .frame(height: size)
                        .padding(.leading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: .rect(cornerRadius: 10, style: .continuous))
                        .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
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
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        })
        .refreshable {
            await healthManager.fetchRunningWorkouts()
        }
        .onAppear {
            groupedWorkouts = WorkoutGroup.groupWorkoutsByMonthAndYear(workouts: healthManager.workouts)
        }
        .onChange(of: healthManager.workouts) { _, newValue in
            groupedWorkouts = WorkoutGroup.groupWorkoutsByMonthAndYear(workouts: newValue)
        }
    }
}

// MARK: - View Components

extension WorkoutsTab {
    
    @ViewBuilder
    private var emptyWorkoutsView: some View {
        if healthManager.workouts.isEmpty {
            ContentUnavailableView {
                Label("No Workouts Available", systemImage: "figure.run.circle")
            } description: {
                Text("There are no running workouts available in your Apple Health data.")
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        WorkoutsTab()
            .navigationTitle("Workouts")
            .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
            .environment(HealthManager.shared)
    }
}
