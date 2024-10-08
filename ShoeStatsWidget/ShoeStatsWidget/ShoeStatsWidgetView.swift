//
//  ShoeStatsWidgetEntryView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftUI
import WidgetKit
import HealthKit

struct ShoeStatsWidgetView: View {
    
    var entry: ShoeStatsWidgetEntry
    
    var body: some View {
        if let stats = entry.shoe {
            ShoeStatsSnapshotWidgetView(shoe: stats, unitSymbol: entry.unitSymbol)
        } else {
            Text("No Shoe")
                .foregroundStyle(.secondary)
                .containerBackground(.fill, for: .widget)
        }
    }
}

struct ShoeStatsSnapshotWidgetView : View {
        
    var shoe: ShoeStatsEntity
    var unitSymbol: String
    
    @State private var height: CGFloat = 0
    @State private var width: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(shoe.nickname)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .italic()
                .foregroundStyle(Color.theme.greenEnergy)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(shoe.brand)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(shoe.model)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.6)
            }
                        
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 2) {
                    StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: unitSymbol, labelFont: .system(size: 10), valueFont: .system(size: 12), color: .blue, textAlignment: .leading, containerAlignment: .leading)

                    StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: unitSymbol, labelFont: .system(size: 10), valueFont: .system(size: 12), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentTransition(.numericText(value: shoe.totalDistance))
                
                ZStack {
                    CircularProgressView(progress: shoe.wearPercentage, lineWidth: 3, color: shoe.wearColor)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                            }
                        )
                    
                    StatCell(label: "WEAR", value: shoe.wearPercentageAsString, labelFont: .system(size: 10), valueFont: .system(size: 12), color: shoe.wearColor)
                        .padding(.horizontal, getPadding())
                        .frame(width: width, height: height)
                        .contentTransition(.numericText(value: shoe.totalDistance))
                }
                .frame(maxHeight: .infinity, alignment: .trailing)
                .onPreferenceChange(WidthPreferenceKey.self) { width in
                    self.width = width
                }
                .onPreferenceChange(HeightPreferenceKey.self) { height in
                    self.height = height
                }
            }
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
    
    private func getPadding() -> CGFloat {
        return (width - height) / 2 + height / 7
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

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

