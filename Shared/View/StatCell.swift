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
    private var labelFont: Font
    private var valueFont: Font
    private var unit: String
    private var color: Color
    private var textAlignment: HorizontalAlignment
    private var containerAlignment: Alignment
    
    init(label: String,
         value: String,
         unit: String = "",
         labelFont: Font = .system(size: 17, weight: .regular, design: .rounded),
         valueFont: Font = .system(size: 20, weight: .regular, design: .rounded),
         color: Color,
         textAlignment: HorizontalAlignment = .center,
         containerAlignment: Alignment = .center) {
        self.label = label
        self.value = value
        self.labelFont = labelFont
        self.valueFont = valueFont
        self.unit = unit
        self.color = color
        self.textAlignment = textAlignment
        self.containerAlignment = containerAlignment
    }
    
    var body: some View {
        VStack(alignment: textAlignment, spacing: 0) {
            Text(label)
                .font(labelFont)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Group {
                Text(value) +
                Text("\(unit.uppercased())")
                    .textScale(.secondary)
            }
            .font(valueFont)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .widgetAccentable(true)
        }
        .frame(maxWidth: .infinity, alignment: containerAlignment)
    }
}

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
