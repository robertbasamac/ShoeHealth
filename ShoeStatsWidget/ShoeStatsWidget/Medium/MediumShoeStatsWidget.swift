//
//  MediumShoeStatsWidget.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct MediumShoeStatsWidget: Widget {
    
    let kind: String = "MediumShoeStatsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MediumShoeSelectionIntent.self,
            provider: MediumShoeStatsAppIntentProvider()
        ) { entry in
            MediumShoeStatsWidgetView(entry: entry)
                .widgetURL(entry.shoe?.url)
        }
        .configurationDisplayName("Shoe Stats")
        .description("Displays health and statistics of the selected shoe.")
        .supportedFamilies([.systemMedium])
    }
}
