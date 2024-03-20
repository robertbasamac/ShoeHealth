//
//  ShoeStat.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.01.2024.
//

import SwiftUI

struct ShoeStatView: View {
    
    private var label: String
    private var value: String
    private var color: Color
    private var labelFont: Font
    private var valueFont: Font
    private var alignement: HorizontalAlignment
    
    init(label: String,
         value: String,
         color: Color,
         labelFont: Font = .caption,
         valueFont: Font = .title3,
         alignement: HorizontalAlignment = .center) {
        self.label = label
        self.value = value
        self.color = color
        self.labelFont = labelFont
        self.valueFont = valueFont
        self.alignement = alignement
    }
    
    var body: some View {
        VStack(alignment: alignement, spacing: 0) {
            Text(label)
                .font(labelFont)
            Text(value)
                .font(valueFont)
                .foregroundStyle(color)
                .contentTransition(.numericText(value: Double(value) ?? 0))
        }
    }
}

// MARK: - Preview

#Preview {
    ShoeStatView(label: "CURRENT", value: "3KM", color: Color.yellow)
}
