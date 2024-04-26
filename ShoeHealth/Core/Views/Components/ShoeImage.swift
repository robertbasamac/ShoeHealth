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
    
    init(imageData: Data? = nil, showBackground: Bool = true) {
        self.imageData = imageData
        self.showBackground = showBackground
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
                    .padding(30)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ShoeImage(imageData: Shoe.previewShoe.image)
}
