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
    
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate { !$0.isRetired }, sort: [SortDescriptor(\Shoe.brand, order: .forward), SortDescriptor(\Shoe.model, order: .forward)]) private var activeShoes: [Shoe]
    @Query(filter: #Predicate { $0.isRetired }, sort: [SortDescriptor(\Shoe.brand, order: .forward), SortDescriptor(\Shoe.model, order: .forward)]) private var retiredShoes: [Shoe]
    
    @State private var selectedShoe: Shoe?
    
    @State private var isExpandedActive: Bool = true
    @State private var isExpandedRetire: Bool = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 84
    
    private let title: String
    private let description: String
    private let systemImage: String
    private let showCancelButton: Bool
    private let onDone: (UUID) -> Void
    
    init (
        selectedShoe: Shoe? = nil,
        title: String,
        description: String,
        systemImage: String,
        showCancelButton: Bool = true,
        onDone: @escaping (
            UUID
        ) -> Void
    ) {
        self.selectedShoe = selectedShoe
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.showCancelButton = showCancelButton
        self.onDone = onDone
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Divider()
            
            List {
                activeShoesSection
                retiredShoesSection
            }
            .listStyle(.sidebar)
            .listRowSpacing(4)
        }
        .toolbar {
            toolbarItems
        }
    }
}

// MARK: - View Components

extension ShoeSelectionView {
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size, alignment: .center)
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
    
    private var activeShoesSection: some View {
        Section(isExpanded: $isExpandedActive, content: {
            shoesList(shoes: activeShoes)
        }, header: {
            Text("Active Shoes")
        })
    }
    
    private var retiredShoesSection: some View {
        Section(isExpanded: $isExpandedRetire, content: {
            shoesList(shoes: retiredShoes)
        }, header: {
            Text("Retired Shoes")
        })
    }
    
    private func shoesList(shoes: [Shoe]) -> some View {
        ForEach(shoes) { shoe in
            HStack(spacing: 4) {
                Image(systemName: shoe.id == selectedShoe?.id ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(isShoeRestricted(shoe.id) ? .gray : Color.theme.accent)
                
                ShoeListItem(
                    shoe: shoe,
                    width: size,
                    imageAlignment: .trailing,
                    showStats: false,
                    showNavigationLink: false,
                    reserveSpace: false
                )
                .disabled(isShoeRestricted(shoe.id))
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
            .contentShape(.rect)
            .onTapGesture {
                if !isShoeRestricted(shoe.id) {
                    selectedShoe = selectedShoe == shoe ? nil : shoe
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        if showCancelButton {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                if let shoe = selectedShoe {
                    onDone(shoe.id)
                }
                
                dismiss()
            } label: {
                Text("Done")
            }
            .disabled(isSaveButtonDisabled())
        }
    }
}

// MARK: - Helper Methods

extension ShoeSelectionView {
    
    private func isShoeRestricted(_ shoeID: UUID) -> Bool {
        return !storeManager.hasFullAccess && shoesViewModel.shouldRestrictShoe(shoeID)
    }
    
    private func isSaveButtonDisabled() -> Bool {
        return selectedShoe == nil
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeSelectionView(selectedShoe: Shoe.previewShoe,
                              title: Prompts.SelectShoe.selectDefaultShoeTitle,
                              description: Prompts.SelectShoe.selectDefaultShoeDescription,
                              systemImage: "shoe.2",
                              onDone: { _ in })
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
