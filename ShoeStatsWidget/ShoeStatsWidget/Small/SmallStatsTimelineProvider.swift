//
//  SmallShoeStatsAppIntentProvider.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftData
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health Widgets", category: "SmallShoeStatsTimelineProvider")

// MARK: - AppIntentTimelineProvider

struct SmallShoeStatsAppIntentProvider: AppIntentTimelineProvider {
    
    let modelContext = ModelContext(ShoesStore.shared.modelContainer)
    
    typealias Entry = SmallShoeStatsWidgetEntry
    typealias Intent = SmallShoeSelectionIntent
    
    func placeholder(in context: Context) -> Entry {
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe }))
            
            guard let shoe = shoes.first else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe)
                    )
                } else {
                    return Entry.empty()
                }
            }
            
            let shoeEntity = ShoeStatsEntity(from: shoe)
            return Entry(
                date: shoe.aquisitionDate,
                shoe: shoeEntity
            )
        } catch {
            logger.error("Error fetching default shoes, \(error).")
        }
        
        if context.isPreview {
            return Entry(
                date: .now,
                shoe: ShoeStatsEntity(from: Shoe.previewShoe)
            )
        } else {
            return Entry.empty()
        }
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe }))
            
            guard let shoe = shoes.first(where: { $0.defaultRunTypes.contains(configuration.runType) }) else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe)
                    )
                } else {
                    return Entry.empty()
                }
            }
            
            if configuration.useDefaultShoe {
                let shoeEntity = ShoeStatsEntity(from: shoe)
                return Entry(
                    date: .now,
                    shoe: shoeEntity
                )
            } else {
                let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: shoe) : nil) // display one default shoe if no other shoe is available
                
                if let shoeEntity = shoeEntityToReturn {
                    return Entry(
                        date: .now,
                        shoe: shoeEntity
                    )
                } else {
                    return Entry.empty()
                }
            }
        } catch {
            logger.error("Error fetching default shoes, \(error).")
        }
        
        let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: Shoe.previewShoe) : nil) // display preview shoe if no other shoe is available
        
        if let shoeEntity = shoeEntityToReturn {
            return Entry(
                date: .now,
                shoe: shoeEntity
            )
        } else {
            return Entry.empty()
        }
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        if configuration.useDefaultShoe {
            do {
                let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe }))
                
                guard let shoe = shoes.first(where: { $0.defaultRunTypes.contains(configuration.runType) }) else {
                    return Timeline(entries: [Entry.empty(runType: configuration.runType)], policy: .never)
                }
                
                let shoeEntity = ShoeStatsEntity(from: shoe)
                let entry = Entry(
                    date: .now,
                    shoe: shoeEntity,
                    runType: configuration.runType
                )
                return Timeline(entries: [entry], policy: .never)
            } catch {
                logger.error("Error fetching shoes, \(error).")
            }
            
            return Timeline(entries: [Entry.empty(runType: configuration.runType)], policy: .never)
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
    let runType: RunType?
    
    init(
        date: Date,
        shoe: ShoeStatsEntity? = nil,
        runType: RunType? = nil
    ) {
        self.date = date
        self.shoe = shoe
        self.runType = runType
    }
    
    static func empty(runType: RunType? = nil) -> Self {
        Self(date: .now, runType: runType)
    }
}
