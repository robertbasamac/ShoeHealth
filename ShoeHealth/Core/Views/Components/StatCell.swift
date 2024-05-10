//
//  StatCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.05.2024.
//

import SwiftUI

struct StatCell: View {
    
    private var title: String
    private var value: String
    private var unit: String
    private var color: Color
    
    init(title: String, value: String, unit: String = "", color: Color) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 17))
            Group {
                Text(value)
                    .font(.system(size: 24))
                
                + Text("\(unit.uppercased())")
                    .font(.system(size: 24))
                    .textScale(.secondary)
            }
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(color)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 8) {
        StatCell(title: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .blue)
        
        Divider()
        
        HStack {
            StatCell(title: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .pink)
            StatCell(title: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .yellow)
        }
        
        Divider()
        
        HStack {
            StatCell(title: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .cyan)
            StatCell(title: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .red)
        }
        
        Divider()
        
        HStack {
            StatCell(title: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .teal)
            StatCell(title: "Distance", value: "5.25", unit: UnitLength.kilometers.symbol, color: .cyan)
        }
    }
    .padding()
    .roundedContainer()
}
