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
    private var width: CGFloat = 200
    
    init(imageData: Data? = nil, showBackground: Bool = true, width: CGFloat) {
        self.imageData = imageData
        self.showBackground = showBackground
        self.width = width
    }
    
    var body: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: width)
        } else {
            ZStack {
                if showBackground {
                    Rectangle()
                        .fill(.gray)
                        .frame(width: width, height: width)

                }
                Image(systemName: "shoe.2.fill")
                    .resizable()
                    .foregroundStyle(.white)
                    .aspectRatio(contentMode: .fit)
                    .padding(30)
                    .frame(width: width, height: width)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ShoeImage(imageData: Shoe.previewShoe.image, width: 200)
}
