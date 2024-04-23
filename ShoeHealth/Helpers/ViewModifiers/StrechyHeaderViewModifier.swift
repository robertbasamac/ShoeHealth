//
//  StrechyHeaderViewModifier.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.04.2024.
//

import Foundation
import SwiftUI

// MARK: - View Modifier

struct StrechyHeaderViewModifier: ViewModifier {
    
    var startingHeight: CGFloat = 300
    var coordinateSpace: CoordinateSpace = .global
    
    func body(content: Content) -> some View {
        GeometryReader(content: { geometry in
            content
                .frame(width: geometry.size.width, height: stretchedHeight(geometry))
                .clipped()
                .offset(y: stretchedOffset(geometry))
        })
        .frame(height: startingHeight)
    }
    
    private func yOffset(_ geo: GeometryProxy) -> CGFloat {
        geo.frame(in: coordinateSpace).minY
    }
    
    private func stretchedHeight(_ geo: GeometryProxy) -> CGFloat {
        let offset = yOffset(geo)
        return offset > 0 ? (startingHeight + offset) : startingHeight
    }
    
    private func stretchedOffset(_ geo: GeometryProxy) -> CGFloat {
        let offset = yOffset(geo)
        return offset > 0 ? -offset : 0
    }
}

// MARK: - View Extension

public extension View {
    
    func asStretchyHeader(startingHeight: CGFloat) -> some View {
        modifier(StrechyHeaderViewModifier(startingHeight: startingHeight))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        ScrollView {
            VStack {
                Rectangle()
                    .fill(Color.green)
                    .overlay(
                        ZStack {                                
                            AsyncImage(url: URL(string: "https://picsum.photos/3169/2377"))
                        }
                    )
                    .asStretchyHeader(startingHeight: 300)
            }
        }
    }
}
