//
//  MultipleShoeSelectionView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 23.08.2024.
//

import SwiftUI
import SwiftData
import HealthKit

struct MultipleShoeSelectionView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) private var healthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectionsDict: [UUID : Shoe] = [:]
    @State private var selectedWorkout: HKWorkout?
    
    private let workoutIDs: [UUID]
    private let title: String
    private let description: String
    private let systemImage: String
    private let onDone: ([UUID : Shoe]) -> Void
    
    init (workoutIDs: [UUID] = [], title: String, description: String, systemImage: String, onDone: @escaping ([UUID : Shoe]) -> Void) {
        self.workoutIDs = workoutIDs
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.onDone = onDone
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Divider()
            
            List {
                workoutsList
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listRowSpacing(4)
            .scrollBounceBehavior(.basedOnSize)
            .navigationDestination(item: $selectedWorkout) { workout in
                ShoeSelectionView(selectedShoe: selectionsDict[workout.id],
                                  title: Prompts.SelectShoe.selectWorkoutShoeTitle,
                                  description: Prompts.SelectShoe.assignWorkoutsDescription,
                                  systemImage: "shoe.2",
                                  showCancelButton: false,
                                  onDone: { shoeID in
                    if let shoe = shoesViewModel.getShoe(forID: shoeID) {
                        selectionsDict[workout.id] = shoe
                    }
                })
            }
        }
        .toolbar {
            toolbarItems
        }
    }
}

// MARK: - View Components

extension MultipleShoeSelectionView {
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84, alignment: .center)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.bold())
            
            Text(description)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.bottom)
        .padding(.horizontal)
    }
    
    private var workoutsList: some View {
        ForEach(healthManager.getWorkouts(forIDs: workoutIDs)) { workout in
            VStack(alignment: .leading, spacing: 0) {
                WorkoutListItem(workout: workout)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                
                if let shoe = selectionsDict[workout.id] {
                    ShoeListItem(shoe: shoe, width: 84, imageAlignment: .leading, showStats: false, showNavigationLink: false)
                        .padding([.leading, .bottom], 8)
                } else {
                    Text("No shoe selected")
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 58)
                        .padding(.vertical, 8)
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                selectedWorkout = workout
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                onDone(selectionsDict)
                dismiss()
            } label: {
                Text("Done")
            }
            .disabled(isSaveButtonDisabled())
        }
    }
}

// MARK: - Helper Methods

extension MultipleShoeSelectionView {
    
    private func isSaveButtonDisabled() -> Bool {
        return selectionsDict.count != workoutIDs.count
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            MultipleShoeSelectionView(title: Prompts.SelectShoe.selectMultipleWorkoutShoeTitle,
                                      description: Prompts.SelectShoe.selectMultipleWorkoutShoeDescription,
                                      systemImage: "figure.run.circle",
                                      onDone: { _ in })
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext, storeManager: StoreManager()))
            .environment(HealthManager.shared)
        }
    }
}
