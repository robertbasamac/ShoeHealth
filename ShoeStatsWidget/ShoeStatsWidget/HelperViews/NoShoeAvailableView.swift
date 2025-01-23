//
//  NoShoeAvailableView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 22.01.2025.
//

import SwiftUI

struct NoShoeAvailableView: View {
    
    var body: some View {
        Link(destination: URL(string: "shoeHealthApp://show-addShoe")!) {
            VStack(spacing: 10) {
                Text("No shoe available")
                    .font(.subheadline)
                Text("Tap to add a shoe")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .dynamicTypeSize(DynamicTypeSize.xSmall)
            .containerBackground(.background, for: .widget)
        }
    }
}

// MARK: - Preview

#Preview {
    NoShoeAvailableView()
}
