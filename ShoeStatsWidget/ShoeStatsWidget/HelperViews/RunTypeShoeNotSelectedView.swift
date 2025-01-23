//
//  RunTypeShoeNotSelectedView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 22.01.2025.
//

import SwiftUI

struct RunTypeShoeNotSelectedView: View {
    
    var runType: RunType
    
    var body: some View {
        Link(destination: URL(string: "shoeHealthApp://show-selectShoe?runType=\(runType.rawValue)")!) {
            VStack(spacing: 10) {
                Text("No Shoe selected for '\(runType.rawValue.capitalized)' Runs")
                    .font(.subheadline)
                Text("Tap to select a shoe")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .dynamicTypeSize(DynamicTypeSize.xSmall)
            .multilineTextAlignment(.center)
            .containerBackground(.background, for: .widget)
        }
    }
}

// MARK: - Preview

#Preview {
    RunTypeShoeNotSelectedView(runType: RunType.daily)
}
