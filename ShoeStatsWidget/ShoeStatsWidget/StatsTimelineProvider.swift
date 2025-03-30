//
//  ShoeStatsAppIntentProvider.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftData
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health Widgets", category: "MediumShoeStatsTimelineProvider")

// MARK: - AppIntentTimelineProvider

struct ShoeStatsAppIntentProvider: AppIntentTimelineProvider {
    
    let modelContext = ModelContext(ShoesStore.shared.modelContainer)
    
    typealias Entry = ShoeStatsWidgetEntry
    typealias Intent = ShoeSelectionIntent
    
    func placeholder(in context: Context) -> Entry {
        let unitSymbol = getUnitSymbol()
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe } ))
            
            guard let shoe = shoes.first else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe),
                        unitSymbol: unitSymbol
                    )
                } else {
                    return Entry.empty()
                }
            }
            
            let shoeEntity = ShoeStatsEntity(from: shoe)
            return Entry(
                date: .now,
                shoe: shoeEntity,
                unitSymbol: unitSymbol
            )
        } catch {
            logger.error("Error fetching shoes, \(error).")
        }
        
        if context.isPreview {
            return Entry(
                date: .now,
                shoe: ShoeStatsEntity(from: Shoe.previewShoe),
                unitSymbol: unitSymbol
            )
        } else {
            return Entry.empty()
        }
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let unitSymbol = getUnitSymbol()
        let isPremium = getPremiumStatus()
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe } ))
            
            guard let shoe = shoes.first(where: { $0.defaultRunTypes.contains(configuration.runType) }) else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe),
                        firstStat: configuration.firstStat,
                        secondStat: configuration.secondStat,
                        unitSymbol: unitSymbol,
                        isPremium: isPremium
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
                    firstStat: configuration.firstStat,
                    secondStat: configuration.secondStat,
                    unitSymbol: unitSymbol,
                    isPremium: isPremium
                )
            } else {
                let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: shoe) : nil)  // display default shoe if no other shoe is available
                
                if let shoeEntity = shoeEntityToReturn {
                    return Entry(
                        date: .now,
                        shoe: shoeEntity,
                        firstStat: configuration.firstStat,
                        secondStat: configuration.secondStat,
                        unitSymbol: unitSymbol,
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
                firstStat: configuration.firstStat,
                secondStat: configuration.secondStat,
                unitSymbol: unitSymbol,
                isPremium: isPremium
            )
        } else {
            return Entry.empty(isPremium: isPremium)
        }
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        let unitSymbol = getUnitSymbol()
        let isPremium = getPremiumStatus()
        
        if configuration.useDefaultShoe {
            do {
                let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe } ))
                
                guard let shoe = shoes.first(where: { $0.defaultRunTypes.contains(configuration.runType) }) else {
                    return Timeline(
                        entries: [Entry.empty(
                            for: configuration.runType,
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
                    firstStat: configuration.firstStat,
                    secondStat: configuration.secondStat,
                    unitSymbol: unitSymbol,
                    isPremium: isPremium
                )
                return Timeline(entries: [entry], policy: .never)
            } catch {
                logger.error("Error fetching shoes, \(error).")
            }
            
            return Timeline(entries: [Entry.empty(for: configuration.runType, isPremium: isPremium)], policy: .never)
        } else {
            let entry = Entry(
                date: .now,
                shoe: configuration.shoeEntity,
                firstStat: configuration.firstStat,
                secondStat: configuration.secondStat,
                unitSymbol: unitSymbol,
                isPremium: isPremium
            )
            return Timeline(entries: [entry], policy: .never)
        }
    }
    
    private func getUnitSymbol() -> String {
        let defaults = UserDefaults(suiteName: System.AppGroups.shoeHealth)
        let savedUnitOfMeasure = defaults?.string(forKey: "UNIT_OF_MEASURE") ?? UnitOfMeasure.metric.rawValue
        let unitOfMeasure = UnitOfMeasure(rawValue: savedUnitOfMeasure) ?? .metric
        
        return unitOfMeasure.symbol
    }
    
    private func getPremiumStatus() -> Bool {
        let defaults = UserDefaults(suiteName: System.AppGroups.shoeHealth)
        let savedPremiumStatus = defaults?.bool(forKey: "IS_PREMIUM_USER") ?? false
        
        return savedPremiumStatus
    }
}

// MARK: - Timeline Entry

struct ShoeStatsWidgetEntry: TimelineEntry {
    
    let date: Date
    let shoe: ShoeStatsEntity?
    let runType: RunType?
    let firstStat: ShoeStatMetric
    let secondStat: ShoeStatMetric
    let unitSymbol: String
    let isPremium: Bool
    
    init(
        date: Date,
        shoe: ShoeStatsEntity? = nil,
        runType: RunType? = nil,
        firstStat: ShoeStatMetric = .averagePace,
        secondStat: ShoeStatMetric = .averageDistance,
        unitSymbol: String = "",
        isPremium: Bool = true
    ) {
        self.date = date
        self.shoe = shoe
        self.runType = runType
        self.unitSymbol = unitSymbol
        self.firstStat = firstStat
        self.secondStat = secondStat
        self.isPremium = isPremium
    }
    
    static func empty(for runType: RunType? = nil, isPremium: Bool = true) -> Self {
        Self(date: .now, runType: runType, isPremium: isPremium)
    }
}
