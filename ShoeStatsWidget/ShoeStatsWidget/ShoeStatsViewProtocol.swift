//
//  ShoeStatsViewProtocol.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.03.2025.
//

import SwiftUI

// MARK: - ShoeStatsViewProtocol

@MainActor
protocol ShoeStatsViewProtocol {
    
    var shoe: ShoeStatsEntity { get }
}

// MARK: - View Components

extension ShoeStatsViewProtocol {
    
    @ViewBuilder
    func statCell(
        label: String,
        value: String,
        unit: String = "",
        color: Color,
        textAlignment: HorizontalAlignment = .center,
        containerAlignment: Alignment = .center,
        showLabel: Bool = true
    ) -> some View {
        VStack(alignment: textAlignment, spacing: 0) {
            if showLabel {
                Text(label)
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Group {
                Text(value) +
                Text("\(unit.uppercased())")
                    .textScale(.secondary)
            }
            .font(.headline)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(color)
            .lineLimit(1)
            .widgetAccentable(true)
        }
        .dynamicTypeSize(DynamicTypeSize.large)
        .frame(alignment: containerAlignment)
    }
}
