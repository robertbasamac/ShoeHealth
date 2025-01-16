//
//  MediumShoeStatsWidgetEntryView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftUI
import WidgetKit

// MARK: - Widget View

struct SmallShoeStatsWidgetView: View {
        
    var entry: SmallShoeStatsWidgetEntry
    
    var body: some View {
        if let shoe = entry.shoe {
            SmallShoeStatsSnapshotWidgetView(shoe: shoe)
        } else {
            Text("No Shoe")
                .foregroundStyle(.secondary)
                .containerBackground(.fill, for: .widget)
        }
    }
}

// MARK: - Snapshot Widget View

struct SmallShoeStatsSnapshotWidgetView : View {
    
    var shoe: ShoeStatsEntity
    
    @State private var height: CGFloat = 0
    @State private var width: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            CircularProgressView(progress: shoe.wearPercentage, lineWidth: 5, color: shoe.wearColor)
                .widgetAccentable(true)
                .overlay {
                    statCell(
                        label: "Wear",
                        value: shoe.wearPercentageAsString,
                        color: shoe.wearColor,
                        containerAlignment: .center,
                        showLabel: false
                    )
                    .padding(.horizontal, 8)
                    .contentTransition(.numericText(value: shoe.totalDistance))
                }
            
            VStack(alignment: .center, spacing: 0) {
                Text(shoe.nickname)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .italic()
                    .foregroundStyle(Color.theme.greenEnergy)
                    .lineLimit(1)
                
                Text(shoe.brand)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .widgetAccentable(true)
                
                Text(shoe.model)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .widgetAccentable(true)
            }
            .dynamicTypeSize(DynamicTypeSize.xSmall)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            ZStack {
                Color.black
                LinearGradient(
                    colors: [.black, shoe.wearColor.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .widgetURL(shoe.url)
    }
}
    
// MARK: - View Components

extension SmallShoeStatsSnapshotWidgetView {
    
    @ViewBuilder
    private func statCell(
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

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    SmallShoeStatsWidget()
} timeline: {
    SmallShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[0]))
    
    SmallShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[1]))
    
    SmallShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[2]))
    
    SmallShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[3]))
}
