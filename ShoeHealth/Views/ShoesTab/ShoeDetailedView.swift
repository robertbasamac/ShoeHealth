//
//  ShoeDetailedView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.11.2023.
//

import SwiftUI

struct ShoeDetailedView: View {
    var shoe: Shoe
    
    var body: some View {
        Text(shoe.model)
    }
}

// MARK: - Previews
#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailedView(shoe: Shoe.previewShoe)
        }
    }
}
