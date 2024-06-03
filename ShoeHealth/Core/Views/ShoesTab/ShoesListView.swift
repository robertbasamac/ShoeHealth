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
    
    init(shoes: [Shoe]) {
        self.shoes = shoes
    }
    
    var body: some View {
        List {
            ForEach(shoes) { shoe in
                ShoeListItem(shoe: shoe, width: 140)
                    .listRowInsets(EdgeInsets())
            }
        }
        .listRowSpacing(8)
        .toolbarRole(.editor)
    }
}

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoesListView(shoes: Shoe.previewShoes + Shoe.previewShoes)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .navigationTitle("Shoes")
        }
    }
}
