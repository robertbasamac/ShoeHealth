//
//  ShoeImage.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 14.01.2024.
//

import SwiftUI

struct ShoeImage: View {
    
    private var imageData: Data?
    private var showBackground: Bool
    private var width: CGFloat
    
    init(imageData: Data? = nil, showBackground: Bool = true, width: CGFloat = 100) {
        self.imageData = imageData
        self.showBackground = showBackground
        self.width = width
    }
    
    var body: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Rectangle()
                .opacity(0.0001)
                .overlay {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipped()
            
        } else {
            ZStack {
                if showBackground {
                    Rectangle()
                        .fill(.gray)
                }
                Image(systemName: "shoe.2.fill")
                    .resizable()
                    .foregroundStyle(.white)
                    .aspectRatio(contentMode: .fit)
                    .padding(width / 4)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ShoeImage(imageData: Shoe.previewShoe.image)
}
