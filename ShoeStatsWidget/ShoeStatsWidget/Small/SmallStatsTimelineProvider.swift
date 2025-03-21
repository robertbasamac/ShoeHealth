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
                date: .now,
                shoe: shoeEntity
            )
        } catch {
            logger.error("Error fetching shoes, \(error).")
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
        let isPremium = getPremiumStatus()
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe } ))
            
            guard let shoe = shoes.first(where: { $0.defaultRunTypes.contains(configuration.runType) }) else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe),
                        isPremium: true
                    )
                } else {
                    return Entry.empty(isPremium: isPremium)
                }
            }
            
            if configuration.useDefaultShoe {
                let shoeEntity = ShoeStatsEntity(from: shoe)
                return Entry(
                    date: .now,
                    shoe: shoeEntity,
                    isPremium: isPremium
                )
            } else {
                let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: shoe) : nil)  // display default shoe if no other shoe is available
                
                if let shoeEntity = shoeEntityToReturn {
                    return Entry(
                        date: .now,
                        shoe: shoeEntity,
                        isPremium: isPremium
                    )
                } else {
                    return Entry.empty(isPremium: isPremium)
                }
            }
        } catch {
            logger.error("Error fetching shoe, \(error).")
        }
        
        let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: Shoe.previewShoe) : nil)  // display preview shoe if no other shoe is available
        
        if let shoeEntity = shoeEntityToReturn {
            return Entry(
                date: .now,
                shoe: shoeEntity,
                isPremium: isPremium
            )
        } else {
            return Entry.empty(isPremium: isPremium)
        }
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        let isPremium: Bool = getPremiumStatus()
        
        if configuration.useDefaultShoe {
            do {
                let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe }))
                
                guard let shoe = shoes.first(where: { $0.defaultRunTypes.contains(configuration.runType) }) else {
                    return Timeline(
                        entries: [Entry.empty(
                            runType: configuration.runType,
                            isPremium: isPremium
                        )],
                        policy: .never
                    )
                }
                
                let shoeEntity = ShoeStatsEntity(from: shoe)
                let entry = Entry(
                    date: .now,
                    shoe: shoeEntity,
                    runType: configuration.runType,
                    isPremium: isPremium
                )
                return Timeline(entries: [entry], policy: .never)
            } catch {
                logger.error("Error fetching shoes, \(error).")
            }
            
            return Timeline(entries: [Entry.empty(runType: configuration.runType, isPremium: isPremium)], policy: .never)
        } else {
            let entry = Entry(
                date: .now,
                shoe: configuration.shoeEntity,
                isPremium: isPremium
            )
            return Timeline(entries: [entry], policy: .never)
        }
    }
    
    private func getPremiumStatus() -> Bool {
        let defaults = UserDefaults(suiteName: System.AppGroups.shoeHealth)
        let savedPremiumStatus = defaults?.bool(forKey: "IS_PREMIUM_USER") ?? false
        
        return savedPremiumStatus
    }
}

// MARK: - Timeline Entry

struct SmallShoeStatsWidgetEntry: TimelineEntry {
    
    let date: Date
    let shoe: ShoeStatsEntity?
    let runType: RunType?
    let isPremium: Bool
    
    init(
        date: Date,
        shoe: ShoeStatsEntity? = nil,
        runType: RunType? = nil,
        isPremium: Bool = true
    ) {
        self.date = date
        self.shoe = shoe
        self.runType = runType
        self.isPremium = isPremium
    }
    
    static func empty(runType: RunType? = nil, isPremium: Bool = true) -> Self {
        Self(date: .now, runType: runType, isPremium: isPremium)
    }
}
