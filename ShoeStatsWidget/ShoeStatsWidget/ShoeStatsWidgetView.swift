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
        if let stats = entry.stats {
            ShoeStatsSnapshotWidgetView(stats: stats)
        } else {
            Text("No Shoe")
                .foregroundStyle(.secondary)
                .containerBackground(.fill, for: .widget)
        }
    }
    
}

struct ShoeStatsSnapshotWidgetView : View {
    var stats: ShoeStatsEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text(stats.brand)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                
                Text(stats.model)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    ShoeStatView(label: "CURRENT", value: "\(distanceFormatter.string(fromValue: stats.currentDistance, unit: .kilometer).uppercased())", color: Color.yellow, labelFont: .system(size: 10), valueFont: .system(size: 12), alignement: .leading)
                    ShoeStatView(label: "REMAINING", value: "\(distanceFormatter.string(fromValue: stats.lifespanDistance - stats.currentDistance, unit: .kilometer).uppercased())", color: Color.blue, labelFont: .system(size: 10), valueFont: .system(size: 12), alignement: .leading)
                }
                .contentTransition(.numericText(value: stats.currentDistance))
                
                ZStack {
                    CircularProgressView(progress: stats.wearPercentage, lineWidth: 4, color: stats.wearColor)
                    ShoeStatView(label: "WEAR", value: "\(stats.wearPercentageAsString.uppercased())", color: stats.wearColor, labelFont: .system(size: 10), valueFont: .system(size: 12))
                        .contentTransition(.numericText(value: stats.currentDistance))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            
            Text("Last Run • \(dateFormatter.string(from: stats.aquisitionDate))")
                .font(.system(size: 10))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            ZStack {
                Color.black
                LinearGradient(colors: [stats.wearColor.opacity(0.5),
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
    ShoeStatsWidgetEntry(date: .now, stats: ShoeStatsEntity(from: Shoe.previewShoe))
}
