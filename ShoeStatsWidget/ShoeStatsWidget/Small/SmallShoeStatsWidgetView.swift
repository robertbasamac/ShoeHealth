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
    
    let storeManager = StoreManager.shared
    
    var entry: SmallShoeStatsWidgetEntry
    
    var body: some View {
        Group {
            if storeManager.hasFullAccess {
                shoeWidgetView
            } else if let runType = entry.runType, runType != .daily {
                VStack(spacing: 10) {
                    Text("'\(runType.rawValue.capitalized)' Run is not available for free users")
                        .font(.subheadline)
                    Text("Tap to show upgrade options")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .dynamicTypeSize(DynamicTypeSize.xSmall)
                .multilineTextAlignment(.center)
                .containerBackground(.background, for: .widget)
                .widgetURL(URL(string: "shoeHealthApp://show-paywall"))
            } else {
                shoeWidgetView
            }
        }
    }
    
    var shoeWidgetView: some View {
        Group {
            if let shoe = entry.shoe {
                SmallShoeStatsSnapshotWidgetView(shoe: shoe)
            } else if let runType = entry.runType {
                VStack(spacing: 10) {
                    Text("No Shoe selected for '\(runType.rawValue.capitalized)' Runs")
                        .font(.subheadline)
                    Text("Tap to select a shoe")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .dynamicTypeSize(DynamicTypeSize.xSmall)
                .multilineTextAlignment(.center)
                .containerBackground(.background, for: .widget)
                .widgetURL(URL(string: "shoeHealthApp://show-selectShoe?runType=\(runType.rawValue)"))
            } else {
                Text("No Shoe")
                    .foregroundStyle(.secondary)
                    .dynamicTypeSize(DynamicTypeSize.xSmall)
                    .containerBackground(.background, for: .widget)
                    .widgetURL(URL(string: "shoeHealthApp://show-addShoe"))
            }
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
