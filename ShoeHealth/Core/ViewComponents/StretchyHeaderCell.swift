//
//  StretchyHeaderCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 22.04.2024.
//

import SwiftUI

struct StretchyHeaderCell: View {
    
    var height: CGFloat = 300
    var model: String
    var brand: String
    var nickname: String
    var date: Date
    var imageData: Data?
    var shadowColor: Color = .black.opacity(0.8)
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Rectangle()
                .opacity(0)
                .overlay {
                    Rectangle().opacity(0.0001)
                        .overlay {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                        .clipped()
                }
                .overlay(alignment: .bottomLeading) {
                    StaticHeaderCell(
                        model: model,
                        brand: brand,
                        nickname: nickname,
                        date: date
                    )
                    .frame(height: 110)
                    .padding(.top, 20)
                    .background {
                        LinearGradient(colors: [shadowColor.opacity(0), shadowColor], startPoint: .top, endPoint: .bottom)
                    }
                }
                .asStretchyHeader(startingHeight: height)
        } else {
            StaticHeaderCell(
                model: model,
                brand: brand,
                nickname: nickname,
                date: date
            )
            .frame(height: 110)
        }
    }
}

// MARK: - Preview

#Preview {
    StretchyHeaderCell(
        model: Shoe.previewShoe.model,
        brand: Shoe.previewShoe.brand,
        nickname: Shoe.previewShoe.nickname,
        date: Shoe.previewShoe.aquisitionDate,
        imageData: Shoe.previewShoe.image
    )
    .background(.gray)
    .frame(maxHeight: .infinity, alignment: .top)
}
