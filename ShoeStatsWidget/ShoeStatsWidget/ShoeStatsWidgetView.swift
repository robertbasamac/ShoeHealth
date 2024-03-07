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
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text(shoe.brand)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                
                Text(shoe.model)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    ShoeStatView(label: "CURRENT", value: "\(distanceFormatter.string(fromValue: shoe.currentDistance, unit: .kilometer).uppercased())", color: Color.yellow, labelFont: .system(size: 10), valueFont: .system(size: 12), alignement: .leading)
                    ShoeStatView(label: "REMAINING", value: "\(distanceFormatter.string(fromValue: shoe.lifespanDistance - shoe.currentDistance, unit: .kilometer).uppercased())", color: Color.blue, labelFont: .system(size: 10), valueFont: .system(size: 12), alignement: .leading)
                }
                .contentTransition(.numericText(value: shoe.currentDistance))
                
                ZStack {
                    CircularProgressView(progress: shoe.wearPercentage, lineWidth: 4, color: shoe.wearColor)
                    ShoeStatView(label: "WEAR", value: "\(shoe.wearPercentageAsString.uppercased())", color: shoe.wearColor, labelFont: .system(size: 10), valueFont: .system(size: 12))
                        .contentTransition(.numericText(value: shoe.currentDistance))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            
            Text("Last Run • \(dateFormatter.string(from: shoe.aquisitionDate))")
                .font(.system(size: 10))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            ZStack {
                Color.black
                LinearGradient(colors: [shoe.wearColor.opacity(0.5),
                                        .black
                                       ],
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
