//
//  ShoeStatsWidgetView.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 10.12.2024.
//

import SwiftUI
import WidgetKit

// MARK: - Widget View

struct ShoeStatsWidgetView: View {
        
    var entry: ShoeStatsWidgetEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if entry.isPremium {
            if let shoe = entry.shoe {
                switch family {
                case .systemSmall:
                    return AnyView(SmallShoeStatsSnapshotView(shoe: shoe))
                case .systemMedium:
                    return AnyView(
                        MediumShoeStatsSnapshotView(
                            shoe: shoe,
                            firstStat: entry.firstStat,
                            secondStat: entry.secondStat,
                            unitSymbol: entry.unitSymbol
                        )
                    )
                default:
                    return AnyView(SmallShoeStatsSnapshotView(shoe: shoe))
                }
                
            } else if let runType = entry.runType {
                return AnyView(RunTypeShoeNotSelectedView(runType: runType))
            } else {
                return AnyView(NoShoeAvailableView())
            }
        } else if let runType = entry.runType, runType != .daily {
            return AnyView(RunTypeNotAvailableView(runType: runType))
        } else {
            if let shoe = entry.shoe {
                switch family {
                case .systemSmall:
                    return AnyView(SmallShoeStatsSnapshotView(shoe: shoe))
                case .systemMedium:
                    return AnyView(
                        MediumShoeStatsSnapshotView(
                            shoe: shoe,
                            firstStat: entry.firstStat,
                            secondStat: entry.secondStat,
                            unitSymbol: entry.unitSymbol
                        )
                    )
                default:
                    return AnyView(SmallShoeStatsSnapshotView(shoe: shoe))
                }
            } else if let runType = entry.runType {
                return AnyView(RunTypeShoeNotSelectedView(runType: runType))
            } else {
                return AnyView(NoShoeAvailableView())
            }
        }
    }
}

// MARK: - Previews

#Preview("Medium", as: .systemMedium) {
    ShoeStatsWidget()
} timeline: {
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[1]), firstStat: .totalDuration, secondStat: .averageDuration, unitSymbol: UnitOfMeasure.metric.symbol)

    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[2]), firstStat: .averagePace, secondStat: .averageDistance, unitSymbol: UnitOfMeasure.metric.symbol)
    
    ShoeStatsWidgetEntry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoes[3]), firstStat: .totalDuration, secondStat: .averagePace, unitSymbol: UnitOfMeasure.metric.symbol)
}
