//
//  RunTypeNotAvailableView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 22.01.2025.
//

import SwiftUI

struct RunTypeNotAvailableView : View {
    
    var runType: RunType
    
    var body: some View {
        Link(destination: URL(string: "shoeHealthApp://show-paywall")!) {
            VStack(spacing: 10) {
                Text("'\(runType.rawValue.capitalized)' Run is not available for free users")
                    .font(.subheadline)
                Text("Tap to show upgrade options")
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
    RunTypeNotAvailableView(runType: RunType.daily)
}
