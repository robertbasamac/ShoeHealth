//
//  ShoeImage.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 14.01.2024.
//

import SwiftUI

struct ShoeImage: View {
    
    private var shoe: Shoe
    private var width: CGFloat
    
    init(shoe: Shoe, width: CGFloat) {
        self.shoe = shoe
        self.width = width
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                .shadow(color: Color.primary, radius: 4)
            
            if let data = shoe.image, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: width / 3, height: width / 4)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 44))
            }
        }
        .frame(width: width / 3, height: width / 4)
    }
}

// MARK: - Preview

#Preview {
    ShoeImage(shoe: .previewShoe, width: 400)
}
