//
//  ShoeStatsWidget.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct ShoeStatsWidget: Widget {
    
    let kind: String = "MediumShoeStatsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ShoeSelectionIntent.self,
            provider: ShoeStatsAppIntentProvider()
        ) { entry in
            ShoeStatsWidgetView(entry: entry)
        }
        .configurationDisplayName("Shoe Stats")
        .description("Displays health and statistics of the selected shoe.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
