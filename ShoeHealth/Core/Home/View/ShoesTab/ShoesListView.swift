//
//  ShoesListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.04.2024.
//

import SwiftUI

struct ShoesListView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    private var shoes: [Shoe] = []
    
    @State private var selectedShoe: Shoe?
    
    init(shoes: [Shoe]) {
        self.shoes = shoes
    }
    
    var body: some View {
        List {
            ForEach(shoes) { shoe in
                ShoeListItem(shoe: shoe, width: 140)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .listRowInsets(.init(top: 2, leading: 16, bottom: 2, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        selectedShoe = shoe
                    }
            }
        }
        .listStyle(.plain)
        .toolbarRole(.editor)
        .navigationDestination(item: $selectedShoe) { shoe in
            ShoeDetailView(shoe: shoe)
        }
    }
}

// MARK: - Preview

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoesListView(shoes: Shoe.previewShoes + Shoe.previewShoes)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .navigationTitle("Shoes")
        }
    }
}
