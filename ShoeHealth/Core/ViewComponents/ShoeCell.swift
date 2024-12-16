//
//  ShoeCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.04.2024.
//

import SwiftUI

struct ShoeCell: View {
    
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    var shoe: Shoe
    var width: CGFloat
    var hideImage: Bool = false
    var displayProgress: Bool = true
    var reserveSpace: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !hideImage {
                ShoeImage(imageData: shoe.image, width: width)
                    .frame(width: width, height: width)
                    .overlay {
                        if displayProgress {
                            RoundedRectangleProgressView(progress: shoe.wearPercentage, color: shoe.wearColor, width: width, cornerRadius: 10)
                        }
                        
                        if !isEnabled {
                            Color.black.opacity(0.4)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(shoe.nickname)
                    .font(.headline)
                    .italic()
                    .foregroundStyle(Color.theme.accent)
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(shoe.brand)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Text(shoe.model)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2, reservesSpace: reserveSpace)
                        .multilineTextAlignment(.leading)
                }
            }
            .dynamicTypeSize(DynamicTypeSize.medium...DynamicTypeSize.xxLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .opacity(isEnabled ? 1 : 0.6)
        }
        .frame(width: width)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @ScaledMetric(relativeTo: .largeTitle) var width: CGFloat = 140
    
    ScrollView(.horizontal) {
        LazyHStack(spacing: 10) {
            ForEach(Shoe.previewShoes) { shoe in
                ShoeCell(shoe: shoe,width: width)
            }
        }
        .padding(.horizontal)
        .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden)
}
