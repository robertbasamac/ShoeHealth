//
//  ShoeStatsTimelineProvider.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import Foundation
import SwiftData
import WidgetKit

struct ShoeStatsTimelineProvider: AppIntentTimelineProvider {
    let modelContext = ModelContext(ShoesStore.container)
    
    typealias Entry = ShoeStatsWidgetEntry
    typealias Intent = SelectShoeIntent
    
    func placeholder(in context: Context) -> Entry {
        let shoes = try! modelContext.fetch(FetchDescriptor<Shoe>())
        guard let shoe = shoes.first else {
            return .empty
        }
        
        let shoeEntity = ShoeStatsEntity(from: shoe)
        return Entry(date: shoe.aquisitionDate, stats: shoeEntity)
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let shoes = try! modelContext.fetch(FetchDescriptor<Shoe>())
        guard let shoe = shoes.first else {
            return .empty
        }
        
        let shoeEntity = ShoeStatsEntity(from: shoe)
        return Entry(date: shoe.aquisitionDate, stats: shoeEntity)
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: .now, stats: configuration.shoeEntity)
        return Timeline(entries: [entry], policy: .never)
    }
}

struct ShoeStatsWidgetEntry: TimelineEntry {
    let date: Date
    let stats: ShoeStatsEntity?
    
    init(date: Date, stats: ShoeStatsEntity? = nil) {
        self.date = date
        self.stats = stats
    }
    
    static var empty: Self {
        Self(date: .now)
    }
}
