//
//  ShoeStatsWidgetEntryView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftUI
import WidgetKit

struct ShoeStatsWidgetView: View {
    var entry: ShoeStatsWidgetEntry
    
    var body: some View {
        if let stats = entry.shoe {
            ShoeStatsSnapshotWidgetView(shoe: stats)
        } else {
            Text("No Shoe")
                .foregroundStyle(.secondary)
                .containerBackground(.fill, for: .widget)
        }
    }
}

struct ShoeStatsSnapshotWidgetView : View {
    var shoe: ShoeStatsEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            VStack(alignment: .leading, spacing: 0) {
                Text(shoe.brand)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text(shoe.model)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
                        
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 2) {
                    StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: UnitLength.kilometers.symbol, labelFont: .system(size: 10), valueFont: .system(size: 12), color: .blue, textAlignment: .leading, containerAlignment: .leading)

                    StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: UnitLength.kilometers.symbol, labelFont: .system(size: 10), valueFont: .system(size: 12), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentTransition(.numericText(value: shoe.totalDistance))
                
                ZStack {
                    CircularProgressView(progress: shoe.wearPercentage, lineWidth: 4, color: shoe.wearColor)
                    StatCell(label: "WEAR", value: shoe.wearPercentageAsString, labelFont: .system(size: 10), valueFont: .system(size: 12), color: shoe.wearColor)
                        .contentTransition(.numericText(value: shoe.totalDistance))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            
            Text("Last Run • \(shoe.lastRunDate != nil ? dateFormatter.string(from: shoe.lastRunDate!) : "N/A")")
                .font(.system(size: 10))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            ZStack {
                Color.black
                LinearGradient(colors: [shoe.wearColor.opacity(0.6), .black],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            }
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    ShoeStatsWidget()
} timeline: {
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoe))
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[2]))
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[3]))
}
