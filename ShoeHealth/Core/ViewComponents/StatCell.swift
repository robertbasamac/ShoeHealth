//
//  StatCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.05.2024.
//

import SwiftUI

struct StatCell: View {
    
    private var label: String
    private var value: String
    private var unit: String
    private var labelFont: Font
    private var valueFont: Font
    private var color: Color
    private var showLabel: Bool
    private var verticalAlignment: Bool
    private var textAlignment: HorizontalAlignment
    private var containerAlignment: Alignment
    private var valueOnTop: Bool
    
    init(label: String,
         value: String,
         unit: String = "",
         labelFont: Font = .caption,
         valueFont: Font = .headline,
         color: Color,
         showLabel: Bool = true,
         verticalAlignment: Bool = true,
         textAlignment: HorizontalAlignment = .center,
         containerAlignment: Alignment = .center,
         valueOnTop: Bool = false) {
        self.label = label
        self.value = value
        self.unit = unit
        self.labelFont = labelFont
        self.valueFont = valueFont
        self.color = color
        self.showLabel = showLabel
        self.verticalAlignment = verticalAlignment
        self.textAlignment = textAlignment
        self.containerAlignment = containerAlignment
        self.valueOnTop = valueOnTop
    }
    
    var body: some View {
        VStack(alignment: textAlignment, spacing: 0) {
            if showLabel && !valueOnTop {
                Text(label)
                    .font(labelFont)
                    .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxLarge)
                    .lineLimit(1)
            }
            
            Group {
                Text(value) +
                Text("\(unit.uppercased())")
                    .textScale(.secondary)
            }
            .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxxLarge)
            .font(valueFont)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(color)
            .lineLimit(1)
            .widgetAccentable(true)
            
            if showLabel && valueOnTop {
                Text(label)
                    .font(labelFont)
                    .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxLarge)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: containerAlignment)
    }
}

// MARK: - Previews

#Preview(traits: .sizeThatFitsLayout) {
    GroupBox {
        VStack(spacing: 8) {
            StatCell(label: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
            
            Divider()
            
            HStack {
                StatCell(label: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .pink, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .yellow, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .cyan, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .red, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .teal, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .cyan, textAlignment: .leading, containerAlignment: .leading)
            }
        }
    }
    .padding()
}
