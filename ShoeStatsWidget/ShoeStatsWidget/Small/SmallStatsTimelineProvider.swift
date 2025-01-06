//
//  SmalltatsTimelineProvider.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftData
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health Widgets", category: "SmallShoeStatsTimelineProvider")

// MARK: - AppIntentTimelineProvider

struct SmallShoeStatsTimelineProvider: AppIntentTimelineProvider {
    
    let modelContext = ModelContext(ShoesStore.container)
    
    typealias Entry = SmallShoeStatsWidgetEntry
    typealias Intent = SmallSelectShoeIntent
    
    func placeholder(in context: Context) -> Entry {
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { !$0.defaultRunTypes.isEmpty }))
            
            guard let shoe = shoes.first else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe)
                    )
                } else {
                    return Entry.empty
                }
            }
            
            let shoeEntity = ShoeStatsEntity(from: shoe)
            return Entry(date: shoe.aquisitionDate, shoe: shoeEntity)
        } catch {
            logger.error("Error fetching shoes, \(error).")
        }
        
        if context.isPreview {
            return Entry(
                date: .now,
                shoe: ShoeStatsEntity(from: Shoe.previewShoe)
            )
        } else {
            return Entry.empty
        }
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { !$0.defaultRunTypes.isEmpty }))
            
            guard let shoe = shoes.first else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe)
                    )
                } else {
                    return Entry.empty
                }
            }
            
            if configuration.useDefaultShoe {
                let shoeEntity = ShoeStatsEntity(from: shoe)
                return Entry(
                    date: .now,
                    shoe: shoeEntity
                )
            } else {
                let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: shoe) : nil)
                
                if let shoeEntity = shoeEntityToReturn {
                    return Entry(
                        date: .now,
                        shoe: shoeEntity
                    )
                } else {
                    return Entry.empty
                }
            }
        } catch {
            logger.error("Error fetching shoe, \(error).")
        }
        
        let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: Shoe.previewShoe) : nil)
        
        if let shoeEntity = shoeEntityToReturn {
            return Entry(
                date: .now,
                shoe: shoeEntity
            )
        } else {
            return Entry.empty
        }
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        if configuration.useDefaultShoe {
            do {
                let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { !$0.defaultRunTypes.isEmpty }))
                
                guard let shoe = shoes.first else {
                    return Timeline(entries: [Entry.empty], policy: .never)
                }
                
                let shoeEntity = ShoeStatsEntity(from: shoe)
                let entry = Entry(
                    date: .now,
                    shoe: shoeEntity
                )
                return Timeline(entries: [entry], policy: .never)
            } catch {
                logger.error("Error fetching shoes, \(error).")
            }
            
            return Timeline(entries: [Entry.empty], policy: .never)
        } else {
            let entry = Entry(
                date: .now,
                shoe: configuration.shoeEntity
            )
            return Timeline(entries: [entry], policy: .never)
        }
    }
}

// MARK: - Timeline Entry

struct SmallShoeStatsWidgetEntry: TimelineEntry {
    
    let date: Date
    let shoe: ShoeStatsEntity?
    
    init(
        date: Date,
        shoe: ShoeStatsEntity? = nil
    ) {
        self.date = date
        self.shoe = shoe
    }
    
    static var empty: Self {
        Self(date: .now)
    }
}
