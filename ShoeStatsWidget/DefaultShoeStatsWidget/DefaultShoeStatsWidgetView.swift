//
//  DefaultShoeStatsWidgetView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 06.03.2024.
//

import SwiftUI
import WidgetKit

struct DefaultShoeWidgetEntry: TimelineEntry {
    let date: Date
    
    var brand: String
    var model: String
    var lifespanDistance: Double
    var currentDistance: Double
    var aquisitionDate: Date
    var wearPercentage: Double
    var wearPercentageAsString: String
    var wearColor: Color
    
    static var placeholderEntry: DefaultShoeWidgetEntry {
        let shoe: Shoe = Shoe.previewShoe
        
        return DefaultShoeWidgetEntry(date: .now,
                           brand: shoe.brand,
                           model: shoe.model,
                           lifespanDistance: shoe.lifespanDistance,
                           currentDistance: shoe.currentDistance,
                           aquisitionDate: shoe.aquisitionDate,
                           wearPercentage: shoe.wearPercentage,
                           wearPercentageAsString: shoe.wearPercentageAsString,
                           wearColor: shoe.wearColor)
    }
}

struct DefaultShoeStatsWidgetView : View {
    var entry: DefaultShoeWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.brand)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                
                Text(entry.model)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    ShoeStatView(label: "CURRENT", value: "\(distanceFormatter.string(fromValue: entry.currentDistance, unit: .kilometer).uppercased())", color: Color.yellow, labelFont: .system(size: 10), valueFont: .system(size: 12), alignement: .leading)
                    ShoeStatView(label: "REMAINING", value: "\(distanceFormatter.string(fromValue: entry.lifespanDistance - entry.currentDistance, unit: .kilometer).uppercased())", color: Color.blue, labelFont: .system(size: 10), valueFont: .system(size: 12), alignement: .leading)
                }
                .contentTransition(.numericText(value: entry.currentDistance))
                
                ZStack {
                    CircularProgressView(progress: entry.wearPercentage, lineWidth: 4, color: entry.wearColor)
                    ShoeStatView(label: "WEAR", value: "\(entry.wearPercentageAsString.uppercased())", color: entry.wearColor, labelFont: .system(size: 10), valueFont: .system(size: 12))
                        .contentTransition(.numericText(value: entry.currentDistance))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            
            Text("Last Run • \(dateFormatter.string(from: entry.aquisitionDate))")
                .font(.system(size: 10))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    DefaultShoeStatsWidget()
} timeline: {
    DefaultShoeWidgetEntry(date: .now,
                brand: Shoe.previewShoe.brand,
                model: Shoe.previewShoe.model,
                lifespanDistance: Shoe.previewShoe.lifespanDistance,
                currentDistance: Shoe.previewShoe.currentDistance,
                aquisitionDate: Shoe.previewShoe.aquisitionDate,
                wearPercentage: Shoe.previewShoe.wearPercentage,
                wearPercentageAsString: Shoe.previewShoe.wearPercentageAsString,
                wearColor: Shoe.previewShoe.wearColor)
    
    DefaultShoeWidgetEntry(date: .now,
                brand: Shoe.previewShoes[2].brand,
                model: Shoe.previewShoes[2].model,
                lifespanDistance: Shoe.previewShoes[2].lifespanDistance,
                currentDistance: Shoe.previewShoes[2].currentDistance,
                aquisitionDate: Shoe.previewShoes[2].aquisitionDate,
                wearPercentage: Shoe.previewShoes[2].wearPercentage,
                wearPercentageAsString: Shoe.previewShoes[2].wearPercentageAsString,
                wearColor: Shoe.previewShoes[2].wearColor)
    
    DefaultShoeWidgetEntry(date: .now,
                brand: Shoe.previewShoes[3].brand,
                model: Shoe.previewShoes[3].model,
                lifespanDistance: Shoe.previewShoes[3].lifespanDistance,
                currentDistance: Shoe.previewShoes[3].currentDistance,
                aquisitionDate: Shoe.previewShoes[3].aquisitionDate,
                wearPercentage: Shoe.previewShoes[3].wearPercentage,
                wearPercentageAsString: Shoe.previewShoes[3].wearPercentageAsString,
                wearColor: Shoe.previewShoes[3].wearColor)
}
