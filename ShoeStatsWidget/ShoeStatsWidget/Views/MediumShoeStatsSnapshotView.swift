//
//  MediumShoeStatsSnapshotView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 30.03.2025.
//

import SwiftUI
import WidgetKit

struct MediumShoeStatsSnapshotView: View, ShoeStatsViewProtocol {
    
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
                        value: "\(shoe.totalDistance.asString(withDecimals: 0))/\(shoe.lifespanDistance.asString(withDecimals: 0))",
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

extension MediumShoeStatsSnapshotView {
    
    @ViewBuilder
    func getStatCell(for metric: ShoeStatMetric) -> some View {
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
                value: shoe.averageDistance.asString(withDecimals: 2),
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
}

// MARK: - Previews

#Preview("Medium", as: .systemMedium) {
    ShoeStatsWidget()
} timeline: {
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[0]), firstStat: .totalDuration, secondStat: .averageDuration, unitSymbol: UnitOfMeasure.metric.symbol)

    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[2]), firstStat: .averagePace, secondStat: .averageDistance, unitSymbol: UnitOfMeasure.metric.symbol)
    
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[3]), firstStat: .totalDuration, secondStat: .averagePace, unitSymbol: UnitOfMeasure.metric.symbol)
}
