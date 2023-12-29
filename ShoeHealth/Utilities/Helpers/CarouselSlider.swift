//
//  CustomPagingSlider.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.12.2023.
//

import SwiftUI

struct CarouselSlider<Content: View, TitleContent: View, Item: RandomAccessCollection>: View where Item: MutableCollection, Item.Element: Identifiable {
    
    /// View Properties
    @Binding var activeID: UUID?
    @State var data: Item

    /// Customization Properties
    var showsIndicator: ScrollIndicatorVisibility = .hidden
    var titleScrollSpeed: CGFloat = 0.75
    var spacing: CGFloat = 10
    
    @ViewBuilder var content: (Item.Element) -> Content
    @ViewBuilder var titleContent: (Item.Element) -> TitleContent
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: spacing) {
                ForEach(data) { item in
                    VStack(spacing: 0) {
                        titleContent(item)
                            .frame(maxWidth: .infinity)
                            .visualEffect { content, geometryProxy in
                                content
                                    .offset(x: scrollOffset(geometryProxy))
                            }
                        
                        content(item)
                    }
                    .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(showsIndicator)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $activeID)
    }
    
    private func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
        
        return -minX * min(titleScrollSpeed, 1.0)
    }
}

#Preview {
    DetailedCarouselShoeView(shoes: Shoe.previewShoes, selectedShoeID: Shoe.previewShoes[2].id)
}
