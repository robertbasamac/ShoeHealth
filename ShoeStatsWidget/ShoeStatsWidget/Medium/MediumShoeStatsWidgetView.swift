//
//  MediumShoeStatsWidgetView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 10.12.2024.
//

import SwiftUI
import WidgetKit

// MARK: - Widget View

struct MediumShoeStatsWidgetView: View {
        
    var entry: MediumShoeStatsWidgetEntry
    
    var body: some View {
        if entry.isPremium {
            if let shoe = entry.shoe {
                return AnyView(
                    MediumShoeStatsSnapshotWidgetView(
                        shoe: shoe,
                        firstStat: entry.firstStat,
                        secondStat: entry.secondStat,
                        unitSymbol: entry.unitSymbol
                    )
                )
            } else if let runType = entry.runType {
                return AnyView(RunTypeShoeNotSelectedView(runType: runType))
            } else {
                return AnyView(NoShoeAvailableView())
            }
        } else if let runType = entry.runType, runType != .daily {
            return AnyView(RunTypeNotAvailableView(runType: runType))
        } else {
            if let shoe = entry.shoe {
                return AnyView(
                    MediumShoeStatsSnapshotWidgetView(
                        shoe: shoe,
                        firstStat: entry.firstStat,
                        secondStat: entry.secondStat,
                        unitSymbol: entry.unitSymbol
                ))
            } else if let runType = entry.runType {
                return AnyView(RunTypeShoeNotSelectedView(runType: runType))
            } else {
                return AnyView(NoShoeAvailableView())
            }
        }
    }
}

// MARK: - Snapshot Widget View

struct MediumShoeStatsSnapshotWidgetView: View {
    
    var shoe: ShoeStatsEntity
    var firstStat: ShoeStatMetric
    var secondStat: ShoeStatMetric
    var unitSymbol: String
    
    var body: some View {
        Link(destination: URL(string: "shoeHealthApp://\(DeepLinkAction.openShoeDetails.rawValue)?shoeID=\(shoe.id)")!) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(shoe.nickname)
                            .font(.headline)
                            .italic()
                            .foregroundStyle(Color.theme.greenEnergy)
                            .lineLimit(1)
                        
                        Text(shoe.brand)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .widgetAccentable(true)
                        
                        Text(shoe.model)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2, reservesSpace: false)
                            .multilineTextAlignment(.leading)
                            .widgetAccentable(true)
                    }
                    .dynamicTypeSize(DynamicTypeSize.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    
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
                }
                
                HStack(spacing: 0) {
                    statCell(
                        label: "Distance",
                        value: "\(Int(shoe.totalDistance))/\(Int(shoe.lifespanDistance.rounded(toPlaces: 0)))",
                        unit: unitSymbol,
                        color: shoe.wearColor,
                        textAlignment: .leading,
                        containerAlignment: .bottomLeading
                    )
                    Spacer(minLength: 8)
                    getStatCell(for: firstStat)
                    Spacer(minLength: 8)
                    getStatCell(for: secondStat)
                }
                .contentTransition(.numericText(value: shoe.totalDistance))
            }
            .foregroundStyle(.white)
            .containerBackground(for: .widget) {
                ZStack {
                    Color.black
                    LinearGradient(
                        colors: [.black, shoe.wearColor.opacity(0.5)],
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                }
            }
        }
    }
}

// MARK: - View Components

extension MediumShoeStatsSnapshotWidgetView {
    
    @ViewBuilder
    private func getStatCell(for metric: ShoeStatMetric) -> some View {
        switch metric {
        case .totalDuration:
            statCell(
                label: metric.rawValue,
                value: shoe.totalDuration,
                color: .yellow,
                textAlignment: .leading,
                containerAlignment: .bottomLeading
            )
            
        case .averageDistance:
            statCell(
                label: metric.rawValue,
                value: shoe.averageDistance.as2DecimalsString(),
                unit: unitSymbol,
                color: .blue,
                textAlignment: .leading,
                containerAlignment: .bottomLeading
            )
            
        case .averagePace:
            statCell(
                label: metric.rawValue,
                value: String(format: "%d'%02d\"", shoe.averagePace.minutes, shoe.averagePace.seconds),
                unit: "/\(unitSymbol)",
                color: .teal,
                textAlignment: .leading,
                containerAlignment: .bottomLeading
            )
            
        case .averageDuration:
            statCell(
                label: metric.rawValue,
                value: shoe.averageDuration,
                color: .yellow,
                textAlignment: .leading,
                containerAlignment: .bottomLeading
            )
        }
    }
    
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

#Preview("Medium", as: .systemMedium) {
    MediumShoeStatsWidget()
} timeline: {
    MediumShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[1]), firstStat: .totalDuration, secondStat: .averageDuration, unitSymbol: UnitOfMeasure.metric.symbol)

    MediumShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[2]), firstStat: .averagePace, secondStat: .averageDistance, unitSymbol: UnitOfMeasure.metric.symbol)
    
    MediumShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[3]), firstStat: .totalDuration, secondStat: .averagePace, unitSymbol: UnitOfMeasure.metric.symbol)
}
