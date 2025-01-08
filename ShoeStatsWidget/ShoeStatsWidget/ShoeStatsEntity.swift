//
//  ShoeStatsEntity.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftUI
import SwiftData
import WidgetKit
import AppIntents
import OSLog

private let logger = Logger(subsystem: "Shoe Health Widgets", category: "SelectShoeIntent")

// MARK: - AppEntity

struct ShoeStatsEntity: AppEntity {
    
    var id: UUID
    var brand: String
    var model: String
    var nickname: String
    var lifespanDistance: Double
    var totalDistance: Double
    var totalDuration: String
    var averageDistance: Double
    var averagePace: (minutes: Int, seconds: Int)
    var averageDuration: String
    var lastRunDate: Date?
    var wearPercentage: Double
    var wearPercentageAsString: String
    var wearColor: Color
    
    init(
        id: UUID,
        brand: String,
        model: String,
        nickname: String,
        lifespanDistance: Double,
        totalDistance: Double,
        totalDuration: String,
        averageDistance: Double,
        averagePace: (Int,Int),
        averageDiration: String,
        lastActivityDate: Date,
        wearPercentage: Double,
        wearPercentageAsString: String,
        wearColor: Color
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.nickname = nickname
        self.lifespanDistance = lifespanDistance
        self.totalDistance = totalDistance
        self.totalDuration = totalDuration
        self.averageDistance = averageDistance
        self.averagePace = averagePace
        self.averageDuration = averageDiration
        self.lastRunDate = lastActivityDate
        self.wearPercentage = wearPercentage
        self.wearPercentageAsString = wearPercentageAsString
        self.wearColor = wearColor
    }
    
    init(from shoe: ShoesSchemaV1.Shoe) {
        self.id = shoe.id
        self.brand = shoe.brand
        self.model = shoe.model
        self.nickname = shoe.nickname
        self.lifespanDistance = shoe.lifespanDistance
        self.totalDistance = shoe.totalDistance
        self.totalDuration = shoe.formattedTotalDuration
        self.averageDistance = shoe.averageDistance
        self.averagePace = shoe.averagePace
        self.averageDuration = shoe.formatterAverageDuration
        self.lastRunDate = shoe.lastActivityDate
        self.wearPercentage = shoe.wearPercentage
        self.wearPercentageAsString = shoe.wearPercentageAsString(withDecimals: 0)
        self.wearColor = shoe.wearColor
    }
    
    init(from shoe: ShoesSchemaV2.Shoe) {
        self.id = shoe.id
        self.brand = shoe.brand
        self.model = shoe.model
        self.nickname = shoe.nickname
        self.lifespanDistance = shoe.lifespanDistance
        self.totalDistance = shoe.totalDistance
        self.totalDuration = shoe.formattedTotalDuration
        self.averageDistance = shoe.averageDistance
        self.averagePace = shoe.averagePace
        self.averageDuration = shoe.formatterAverageDuration
        self.lastRunDate = shoe.lastActivityDate
        self.wearPercentage = shoe.wearPercentage
        self.wearPercentageAsString = shoe.wearPercentageAsString(withDecimals: 0)
        self.wearColor = shoe.wearColor
    }
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Shoe"
    static let defaultQuery = ShoeStatsQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(nickname)", subtitle: "\(brand) - \(model)")
    }
}

// MARK: - EntityStringQuery

struct ShoeStatsQuery: EntityStringQuery {
    
    func entities(matching string: String) async -> [ShoeStatsEntity] {
        let modelContext = ModelContext(ShoesStore.shared.modelContainer)
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.brand.contains(string) || $0.model.contains(string) },
                                                                        sortBy: [.init(\.brand), .init(\.model)]))
            return shoes.map { ShoeStatsEntity(from: $0) }
        } catch {
            logger.error("Error fetching shoes, \(error).")
        }
        
        return []
    }
    
    func entities(for identifiers: [ShoeStatsEntity.ID]) async -> [ShoeStatsEntity] {
        let modelContext = ModelContext(ShoesStore.shared.modelContainer)
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { identifiers.contains($0.id) },
                                                                      sortBy: [.init(\.brand), .init(\.model)]))
            return shoes.map { ShoeStatsEntity(from: $0) }
        } catch {
            logger.error("Error fetching shoes, \(error).")
        }
        
        return []
    }
    
    func suggestedEntities() async -> [ShoeStatsEntity] {
        let modelContext = ModelContext(ShoesStore.shared.modelContainer)
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(sortBy: [.init(\.brand), .init(\.model)]))
            return shoes.map { ShoeStatsEntity(from: $0) }
        } catch {
            logger.error("Error fetching shoes, \(error).")
        }
        
        return []
    }
}

// MARK: - ShoeStatMetric

enum ShoeStatMetric: String, CaseIterable, AppEnum {
    
    case totalDuration     = "Total Time"
    case averageDistance   = "Avg Distance"
    case averagePace       = "Avg Pace"
    case averageDuration   = "Avg Time"
    
    // The display name for this enum
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Shoe Stat Metric"
    }
    
    // Display names for each case
    static var caseDisplayRepresentations: [ShoeStatMetric: DisplayRepresentation] {
        [
            .totalDuration: DisplayRepresentation(
                title: "Total Time",
                subtitle: "The accumulated time of all runs"
            ),
            .averageDistance: DisplayRepresentation(
                title: "Average Distance",
                subtitle: "The average distance covered"
            ),
            .averagePace: DisplayRepresentation(
                title: "Average Pace",
                subtitle: "The average pace maintained"
            ),
            .averageDuration: DisplayRepresentation(
                title: "Average Time",
                subtitle: "The average workout time"
            )
        ]
    }
}
