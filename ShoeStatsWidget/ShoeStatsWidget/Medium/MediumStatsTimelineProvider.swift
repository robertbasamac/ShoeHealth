//
//  MediumStatsTimelineProvider.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftData
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health Widgets", category: "ShoeStatsTimelineProvider")

// MARK: - AppIntentTimelineProvider

struct MediumShoeStatsTimelineProvider: AppIntentTimelineProvider {
    
    let modelContext = ModelContext(ShoesStore.container)
    
    typealias Entry = MediumShoeStatsWidgetEntry
    typealias Intent = MediumSelectShoeIntent
    
    func placeholder(in context: Context) -> Entry {
        let unitSymbol = getUnitSymbol()
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe } ))
            
            guard let shoe = shoes.first else {
                if context.isPreview {
                    return Entry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoe), unitSymbol: unitSymbol)
                } else {
                    return Entry.empty
                }
            }
            
            let shoeEntity = ShoeStatsEntity(from: shoe)
            return Entry(date: shoe.aquisitionDate, shoe: shoeEntity, unitSymbol: unitSymbol)
        } catch {
            logger.error("Error fetching shoes, \(error).")
        }
        
        if context.isPreview {
            return Entry(date: .now, shoe: ShoeStatsEntity(from: Shoe.previewShoe), unitSymbol: unitSymbol)
        } else {
            return Entry.empty
        }
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let unitSymbol = getUnitSymbol()
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe } ))
            
            guard let shoe = shoes.first else {
                if context.isPreview {
                    return Entry(
                        date: .now,
                        shoe: ShoeStatsEntity(from: Shoe.previewShoe),
                        firstStat: configuration.firstStat,
                        secondStat: configuration.secondStat,
                        unitSymbol: unitSymbol
                    )
                } else {
                    return Entry.empty
                }
            }
            
            if configuration.useDefaultShoe {
                let shoeEntity = ShoeStatsEntity(from: shoe)
                return Entry(
                    date: .now,
                    shoe: shoeEntity,
                    firstStat: configuration.firstStat,
                    secondStat: configuration.secondStat,
                    unitSymbol: unitSymbol
                )
            } else {
                let shoeEntityToReturn = configuration.shoeEntity ?? (context.isPreview ? ShoeStatsEntity(from: shoe) : nil)
                
                if let shoeEntity = shoeEntityToReturn {
                    return Entry(
                        date: .now,
                        shoe: shoeEntity,
                        firstStat: configuration.firstStat,
                        secondStat: configuration.secondStat,
                        unitSymbol: unitSymbol
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
                shoe: shoeEntity,
                firstStat: configuration.firstStat,
                secondStat: configuration.secondStat,
                unitSymbol: unitSymbol
            )
        } else {
            return Entry.empty
        }
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        let unitSymbol = getUnitSymbol()
        
        if configuration.useDefaultShoe {
            do {
                let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe } ))
                
                guard let shoe = shoes.first else {
                    return Timeline(entries: [Entry.empty], policy: .never)
                }
                
                let shoeEntity = ShoeStatsEntity(from: shoe)
                let entry = Entry(
                    date: .now,
                    shoe: shoeEntity,
                    firstStat: configuration.firstStat,
                    secondStat: configuration.secondStat,
                    unitSymbol: unitSymbol
                )
                return Timeline(entries: [entry], policy: .never)
            } catch {
                logger.error("Error fetching shoes, \(error).")
            }
            
            return Timeline(entries: [Entry.empty], policy: .never)
        } else {
            let entry = Entry(
                date: .now,
                shoe: configuration.shoeEntity,
                firstStat: configuration.firstStat,
                secondStat: configuration.secondStat,
                unitSymbol: unitSymbol
            )
            return Timeline(entries: [entry], policy: .never)
        }
    }
    
    private func getUnitSymbol() -> String {
        let defaults = UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")
        let savedUnitOfMeasure = defaults?.string(forKey: "UNIT_OF_MEASURE") ?? UnitOfMeasure.metric.rawValue
        let unitOfMeasure = UnitOfMeasure(rawValue: savedUnitOfMeasure) ?? .metric
        
        return unitOfMeasure.symbol
    }
}

// MARK: - Timeline Entry

struct MediumShoeStatsWidgetEntry: TimelineEntry {
    
    let date: Date
    let shoe: ShoeStatsEntity?
    let firstStat: ShoeStatMetric
    let secondStat: ShoeStatMetric
    let unitSymbol: String
    
    init(
        date: Date,
        shoe: ShoeStatsEntity? = nil,
        firstStat: ShoeStatMetric = .averagePace,
        secondStat: ShoeStatMetric = .averageDistance,
        unitSymbol: String = ""
    ) {
        self.date = date
        self.shoe = shoe
        self.unitSymbol = unitSymbol
        self.firstStat = firstStat
        self.secondStat = secondStat
    }
    
    static var empty: Self {
        Self(date: .now)
    }
}
