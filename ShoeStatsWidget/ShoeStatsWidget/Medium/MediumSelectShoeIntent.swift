//
//  MediumSelectShoeIntent.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 10.12.2024.
//

import SwiftUI
import WidgetKit
import AppIntents
import OSLog

// MARK: - WidgetConfigurationIntent

struct MediumSelectShoeIntent: WidgetConfigurationIntent {
    
    static let title: LocalizedStringResource = "Select Shoe"
    static let description: IntentDescription = IntentDescription("Selects the shoe to display stats for.")
    
    @Parameter(title: "Use Default Shoe", default: true)
    var useDefaultShoe: Bool
    
    @Parameter(title: "for Run Type", default: RunType.daily)
    var runType: RunType
    
    @Parameter(title: "Shoe", default: nil)
    var shoeEntity: ShoeStatsEntity?
    
    @Parameter(title: "First Stat", default: ShoeStatMetric.averagePace)
    var firstStat: ShoeStatMetric
    
    @Parameter(title: "Second Stat", default: ShoeStatMetric.averageDistance)
    var secondStat: ShoeStatMetric
    
    static var parameterSummary: some ParameterSummary {
        When(\.$useDefaultShoe, .equalTo, true) {
            Summary("Use Default Shoe \(\.$useDefaultShoe)") {
                \.$runType; \.$firstStat; \.$secondStat
            }
        } otherwise: {
            Summary("Shoe \(\.$useDefaultShoe)") {
                \.$shoeEntity; \.$firstStat; \.$secondStat
            }
        }
    }
}
