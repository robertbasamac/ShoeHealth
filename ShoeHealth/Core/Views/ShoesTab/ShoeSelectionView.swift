//
//  ShoeSelectionView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 27.11.2023.
//

import SwiftUI
import SwiftData
import HealthKit

struct ShoeSelectionView<Content: View>: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate { !$0.isRetired }, sort: [SortDescriptor(\Shoe.brand, order: .forward), SortDescriptor(\Shoe.model, order: .forward)]) private var activeShoes: [Shoe]
    @Query(filter: #Predicate { $0.isRetired }, sort: [SortDescriptor(\Shoe.brand, order: .forward), SortDescriptor(\Shoe.model, order: .forward)]) private var retiredShoes: [Shoe]
    
    @State private var selectedShoe: Shoe?
    
    @State private var isExpandedActive: Bool = true
    @State private var isExpandedRetire: Bool = false
    
    private let content: () -> Content
    private let onDone: (UUID) -> Void
    
    init (selectedShoe: Shoe? = nil, @ViewBuilder header content: @escaping () -> Content, onDone: @escaping (UUID) -> Void) {
        self.selectedShoe = selectedShoe
        self.content = content
        self.onDone = onDone
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
                .frame(maxWidth: .infinity)
                .padding(40)
            
            Divider()
            
            List {
                Section(isExpanded: $isExpandedActive, content: {
                    ForEach(activeShoes) { shoe in
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
                }, header: {
                    Text("Active Shoes")
                })
                
                Section(isExpanded: $isExpandedRetire, content: {
                    ForEach(retiredShoes) { shoe in
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
                }, header: {
                    Text("Retired Shoes")
                })
            }
            .listStyle(SidebarListStyle())
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
        
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
        }
        
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

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeSelectionView(selectedShoe: Shoe.previewShoes.first) {
                Text("Select a Shoe")
            } onDone: { _ in
                
            }
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
