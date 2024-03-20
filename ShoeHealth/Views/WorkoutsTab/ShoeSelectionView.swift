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
    
    private var onDone: (UUID) -> Void
    
    init (_ onDone: @escaping (UUID) -> Void) {
        self.onDone = onDone
        
        self._shoes = Query(filter: #Predicate<Shoe> { shoe in
            !shoe.retired
        }, sort: [SortDescriptor(\Shoe.brand, order: .forward), SortDescriptor(\Shoe.model, order: .forward)])
    }
    
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
    }
}

// MARK: - View Components
extension ShoeSelectionView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                if let shoe = selectedShoe {
                    onDone(shoe.id)
                }
                
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
    
    private func isSaveButtonDisabled() -> Bool {
        return selectedShoe == nil
    }
}
