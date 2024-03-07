//
//  ShoeStatsWidget.swift
//  ShoeStatsWidget
//
//  Created by Robert Basamac on 05.03.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct ShoeStatsWidget: Widget {
    let kind: String = "ShoeStatsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectShoeIntent.self,
            provider: ShoeStatsTimelineProvider()
        ) { entry in
            ShoeStatsWidgetView(entry: entry)
        }
        .configurationDisplayName("Shoe Stats")
        .description("Displays stats of the selected shoe.")
        .supportedFamilies([.systemSmall])
    }
}
