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
    
    @Environment(\.widgetFamily) var family
    
    var entry: ShoeStatsWidgetEntry
    
    var body: some View {
        if let stats = entry.shoe {
            switch family {
            case .systemSmall:
                SmallShoeStatsSnapshotWidgetView(shoe: stats, unitSymbol: entry.unitSymbol)
            case .systemMedium:
                MediumShoeStatsSnapshotWidgetView(shoe: stats, unitSymbol: entry.unitSymbol)
            default:
                SmallShoeStatsSnapshotWidgetView(shoe: stats, unitSymbol: entry.unitSymbol)
            }
        } else {
            Text("No Shoe")
                .foregroundStyle(.secondary)
                .containerBackground(.fill, for: .widget)
        }
    }
}

// MARK: - Small Widget View

struct SmallShoeStatsSnapshotWidgetView : View {
    
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
                .widgetAccentable(true)
            
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
            .widgetAccentable(true)
                        
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 2) {
                    StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: unitSymbol, labelFont: .system(size: 10), valueFont: .system(size: 12), color: .blue, textAlignment: .leading, containerAlignment: .leading)

                    StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: unitSymbol, labelFont: .system(size: 10), valueFont: .system(size: 12), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentTransition(.numericText(value: shoe.totalDistance))
                
                ZStack {
                    CircularProgressView(progress: shoe.wearPercentage, lineWidth: 3, color: shoe.wearColor)
                        .widgetAccentable(true)
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
                RadialGradient(gradient: Gradient(colors: [.black, shoe.wearColor.opacity(0.5)]), center: .init(x: 0.72, y: 0.72), startRadius: 0, endRadius: 150)
            }
        }
    }
    
    private func getPadding() -> CGFloat {
        return (width - height) / 2 + height / 7
    }
}

// MARK: - Medium Widget View

struct MediumShoeStatsSnapshotWidgetView : View {
        
    var shoe: ShoeStatsEntity
    var unitSymbol: String
    
    @State private var height: CGFloat = 0
    @State private var width: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(shoe.nickname)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .italic()
                    .foregroundStyle(Color.theme.greenEnergy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .widgetAccentable(true)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(shoe.brand)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Text(shoe.model)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .lineLimit(2, reservesSpace: true)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.6)
                }
                .widgetAccentable(true)
                
                HStack(spacing: 2) {
                    StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: unitSymbol, labelFont: .system(size: 14), valueFont: .system(size: 16), color: .blue, textAlignment: .leading, containerAlignment: .leading)
                    
                    StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: unitSymbol, labelFont: .system(size: 14), valueFont: .system(size: 16), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .contentTransition(.numericText(value: shoe.totalDistance))
            }
            
            ZStack {
                CircularProgressView(progress: shoe.wearPercentage, lineWidth: 5, color: shoe.wearColor)
                    .widgetAccentable(true)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                                .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                        }
                    )
                
                StatCell(label: "WEAR", value: shoe.wearPercentageAsString, labelFont: .system(size: 14), valueFont: .system(size: 16), color: shoe.wearColor)
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
        .foregroundStyle(.white)
        .containerBackground(for: .widget) {
            ZStack {
                Color.black
                RadialGradient(gradient: Gradient(colors: [.black, shoe.wearColor.opacity(0.5)]), center: .init(x: 0.77, y: 0.5), startRadius: 0, endRadius: 275)
            }
        }
    }
    
    private func getPadding() -> CGFloat {
        return (width - height) / 2 + height / 7
    }
}

// MARK: - Width and Height Preference Keys

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

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    ShoeStatsWidget()
} timeline: {
    return Shoe.previewShoes.map { shoe in
        ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: shoe))
    }
}

#Preview("Medium", as: .systemMedium) {
    ShoeStatsWidget()
} timeline: {
    return Shoe.previewShoes.map { shoe in
        ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: shoe))
    }
}
