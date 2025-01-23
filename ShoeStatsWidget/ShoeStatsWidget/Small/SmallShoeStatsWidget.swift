//
//  SmallShoeStatsWidget.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct SmallShoeStatsWidget: Widget {
    
    let kind: String = "SmallShoeStatsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SmallShoeSelectionIntent.self,
            provider: SmallShoeStatsAppIntentProvider()
        ) { entry in
            SmallShoeStatsWidgetView(entry: entry)
        }
        .configurationDisplayName("Shoe Stats")
        .description("Displays health of the selected shoe.")
        .supportedFamilies([.systemSmall])
    }
}
