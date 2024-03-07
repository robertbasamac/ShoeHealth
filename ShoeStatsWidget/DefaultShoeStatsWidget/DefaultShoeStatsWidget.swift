//
//  DefaultShoeStatsWidget.swift
//  DefaultShoeStatsWidget
//
//  Created by Robert Basamac on 12.02.2024.
//

import WidgetKit
import SwiftUI

struct DefaultShoeStatsWidget: Widget {
    let kind: String = "DefaultShoeStatsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DefaultShoeStatsTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                DefaultShoeStatsWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        ZStack {
                            Color.black
                            LinearGradient(colors: [entry.wearColor.opacity(0.5),
                                                    .black
                                                   ],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        }
                    }
//                    .modelContainer(for: [Shoe.self])
            } else {
                DefaultShoeStatsWidgetView(entry: entry)
                    .padding()
                    .background {
                        ZStack {
                            Color.black
                            LinearGradient(colors: [entry.wearColor.opacity(0.5),
                                                    .black
                            ],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        }
                    }
//                    .modelContainer(for: [Shoe.self])
            }
        }
        .configurationDisplayName("Default Shoe Stats")
        .description("Displays stats of the user's default shoe.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    DefaultShoeStatsWidget()
} timeline: {
    DefaultShoeWidgetEntry(date: .now,
                brand: Shoe.previewShoe.brand,
                model: Shoe.previewShoe.model,
                lifespanDistance: Shoe.previewShoe.lifespanDistance,
                currentDistance: Shoe.previewShoe.currentDistance,
                aquisitionDate: Shoe.previewShoe.aquisitionDate,
                wearPercentage: Shoe.previewShoe.wearPercentage,
                wearPercentageAsString: Shoe.previewShoe.wearPercentageAsString,
                wearColor: Shoe.previewShoe.wearColor)
    
    DefaultShoeWidgetEntry(date: .now,
                brand: Shoe.previewShoes[2].brand,
                model: Shoe.previewShoes[2].model,
                lifespanDistance: Shoe.previewShoes[2].lifespanDistance,
                currentDistance: Shoe.previewShoes[2].currentDistance,
                aquisitionDate: Shoe.previewShoes[2].aquisitionDate,
                wearPercentage: Shoe.previewShoes[2].wearPercentage,
                wearPercentageAsString: Shoe.previewShoes[2].wearPercentageAsString,
                wearColor: Shoe.previewShoes[2].wearColor)
    
    DefaultShoeWidgetEntry(date: .now,
                brand: Shoe.previewShoes[3].brand,
                model: Shoe.previewShoes[3].model,
                lifespanDistance: Shoe.previewShoes[3].lifespanDistance,
                currentDistance: Shoe.previewShoes[3].currentDistance,
                aquisitionDate: Shoe.previewShoes[3].aquisitionDate,
                wearPercentage: Shoe.previewShoes[3].wearPercentage,
                wearPercentageAsString: Shoe.previewShoes[3].wearPercentageAsString,
                wearColor: Shoe.previewShoes[3].wearColor)
}
