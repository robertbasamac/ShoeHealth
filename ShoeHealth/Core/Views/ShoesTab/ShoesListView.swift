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
                Section {
                    ShoeListItem(shoe: shoe, width: 140)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
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
