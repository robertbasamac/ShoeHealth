//
//  ShoeCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.04.2024.
//

import SwiftUI

struct ShoeCell: View {
    
    var shoe: Shoe
    var width: CGFloat = 140
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ShoeImage(imageData: shoe.image, showBackground: true, width: width)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading) {
                Text(shoe.brand)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(shoe.model)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
        }
        .frame(width: width)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal) {
        LazyHStack(spacing: 10) {
            ForEach(Shoe.previewShoes) { shoe in
                ShoeCell(shoe: shoe)
            }
        }
        .padding(.horizontal)
        .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden)
}
