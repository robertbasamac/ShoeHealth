//
//  ShoeDetailedView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.11.2023.
//

import SwiftUI

struct ShoeDetailedView: View {
    var shoes: [Shoe]

    @State var selectedShoeID: UUID?
    
    init(shoes: [Shoe], selectedShoeID: UUID) {
        self.shoes = shoes
        self._selectedShoeID = State(initialValue: selectedShoeID)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                GeometryReader {
                    let size = $0.size
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(shoes) { shoe in
                                ShoeCardView(shoe: shoe)
                                    .padding()
                                    .background(Color(uiColor: .tertiarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                                    .padding(.horizontal)
                                    .frame(width: size.width)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $selectedShoeID)
                    .scrollTargetBehavior(.paging)
                }
                .frame(height: 150) // TODO: adjust height based on view's child content size
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews
#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailedView(shoes: Shoe.previewShoes, selectedShoeID: Shoe.previewShoes[2].id)
        }
    }
}
