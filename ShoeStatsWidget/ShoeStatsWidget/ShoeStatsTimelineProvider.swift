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
        return Entry(date: shoe.aquisitionDate, shoe: shoeEntity)
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let shoes = try! modelContext.fetch(FetchDescriptor<Shoe>())
        guard let shoe = shoes.first else {
            return .empty
        }
        
        let shoeEntity = ShoeStatsEntity(from: shoe)
        return Entry(date: shoe.aquisitionDate, shoe: shoeEntity)
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        if configuration.useDefaultShoe {
            let shoe = try! modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe })).first!
            let shoeEntity = ShoeStatsEntity(from: shoe)

            let entry = Entry(date: .now, shoe: shoeEntity)
            return Timeline(entries: [entry], policy: .never)
        } else {
            let entry = Entry(date: .now, shoe: configuration.shoeEntity)
            return Timeline(entries: [entry], policy: .never)
        }
    }
}

struct ShoeStatsWidgetEntry: TimelineEntry {
    let date: Date
    let shoe: ShoeStatsEntity?
    
    init(date: Date, shoe: ShoeStatsEntity? = nil) {
        self.date = date
        self.shoe = shoe
    }
    
    static var empty: Self {
        Self(date: .now)
    }
}
