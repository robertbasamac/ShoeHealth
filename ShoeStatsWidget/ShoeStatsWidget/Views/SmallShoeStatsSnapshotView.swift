//
//  SmallShoeStatsSnapshotView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 30.03.2025.
//

import SwiftUI
import WidgetKit

struct SmallShoeStatsSnapshotView : View, ShoeStatsViewProtocol {
    
    var shoe: ShoeStatsEntity
    var unitSymbol: String { "" }
    
    var body: some View {
        Link(destination: URL(string: "shoeHealthApp://\(DeepLinkAction.openShoeDetails.rawValue)?shoeID=\(shoe.id)")!) {
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
        }
    }
}

// MARK: - Previews

#Preview("Medium", as: .systemSmall) {
    ShoeStatsWidget()
} timeline: {
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[1]), firstStat: .totalDuration, secondStat: .averageDuration, unitSymbol: UnitOfMeasure.metric.symbol)

    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[2]), firstStat: .averagePace, secondStat: .averageDistance, unitSymbol: UnitOfMeasure.metric.symbol)
    
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[3]), firstStat: .totalDuration, secondStat: .averagePace, unitSymbol: UnitOfMeasure.metric.symbol)
}
