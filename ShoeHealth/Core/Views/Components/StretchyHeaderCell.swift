//
//  StretchyHeaderCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 22.04.2024.
//

import SwiftUI

struct StretchyHeaderCell: View {
    
    var height: CGFloat = 300
    var title: String
    var subtitle: String
    var imageData: Data?
    var shadowColor: Color = .black.opacity(0.8)
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay {
                Rectangle().opacity(0.0001)
                    .overlay {
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                    }
                    .clipped()
            }
            .overlay(alignment: .bottomLeading) {
                StaticHeaderCell(title: title, subtitle: subtitle)
                .background {
                    LinearGradient(colors: [shadowColor.opacity(0), shadowColor], startPoint: .top, endPoint: .bottom)
                }
            }
            .asStretchyHeader(startingHeight: height)
    }
}

// MARK: - Preview

#Preview {
    StretchyHeaderCell(title: "Pegasus 40", subtitle: "nike", imageData: Shoe.previewShoe.image)
}
