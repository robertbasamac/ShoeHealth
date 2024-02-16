//
//  ShoeSelectionView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 27.11.2023.
//

import SwiftUI
import SwiftData
import HealthKit

struct ShoeSelectionView: View {
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\Shoe.brand, order: .forward), SortDescriptor(\Shoe.model, order: .forward)]) private var shoes: [Shoe]
    
    @State private var selectedShoe: Shoe?
    @State private var previousShoe: Shoe?
    
    var workout: HKWorkout
    
    var body: some View {
        List {
            ForEach(shoes) { shoe in
                HStack {
                    Image(systemName: shoe.id == selectedShoe?.id ? "checkmark.circle.fill" : "circle")
                    Text("\(shoe.brand) - \(shoe.model)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
                .onTapGesture {
                    selectedShoe = selectedShoe == shoe ? nil : shoe
                }
            }
        }
        .toolbar {
            toolbarItems()
        }
        .onAppear {
            shoes.forEach { shoe in
                if shoe.workouts.contains(where: { $0 == workout.uuid }) {
                    previousShoe = shoe
                    selectedShoe = shoe
                    return
                }
            }
        }
    }
}

// MARK: - View Components
extension ShoeSelectionView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                updateShoes()
                
                dismiss()
            } label: {
                Text("Save")
            }
            .disabled(isSaveButtonDisabled())
        }
    }
}

// MARK: - Helper Methods
extension ShoeSelectionView {
    
    private func updateShoes() {
        if let previousShoe = previousShoe {
            shoesViewModel.remove(workout: self.workout.id, fromShoe: previousShoe.id)
        }
        
        shoesViewModel.add(workouts: [workout.id], toShoe: selectedShoe?.id ?? UUID())
    }
    
    private func isSaveButtonDisabled() -> Bool {
        return selectedShoe == previousShoe
    }
}
