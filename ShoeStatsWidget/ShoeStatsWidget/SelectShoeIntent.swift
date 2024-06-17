//
//  SelectShoeIntent.swift
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
    var lifespanDistance: Double
    var totalDistance: Double
    var lastRunDate: Date?
    var wearPercentage: Double
    var wearPercentageAsString: String
    var wearColor: Color
    
    init(id: UUID, brand: String, model: String, lifespanDistance: Double, totalDistance: Double, lastActivityDate: Date, wearPercentage: Double, wearPercentageAsString: String, wearColor: Color) {
        self.id = id
        self.brand = brand
        self.model = model
        self.lifespanDistance = lifespanDistance
        self.totalDistance = totalDistance
        self.lastRunDate = lastActivityDate
        self.wearPercentage = wearPercentage
        self.wearPercentageAsString = wearPercentageAsString
        self.wearColor = wearColor
    }
    
    init(from shoe: Shoe) {
        self.id = shoe.id
        self.brand = shoe.brand
        self.model = shoe.model
        self.lifespanDistance = shoe.lifespanDistance
        self.totalDistance = shoe.totalDistance
        self.lastRunDate = shoe.lastActivityDate
        self.wearPercentage = shoe.wearPercentage
        self.wearPercentageAsString = shoe.wearPercentageAsString
        self.wearColor = shoe.wearColor
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(brand) - \(model)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Shoe"
    static var defaultQuery = ShoeStatsQuery()
}

// MARK: - EntityStringQuery

struct ShoeStatsQuery: EntityStringQuery {
    
    func entities(matching string: String) async -> [ShoeStatsEntity] {
        let modelContext = ModelContext(ShoesStore.container)
        
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
        let modelContext = ModelContext(ShoesStore.container)
        
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
        let modelContext = ModelContext(ShoesStore.container)
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor<Shoe>(sortBy: [.init(\.brand), .init(\.model)]))
            return shoes.map { ShoeStatsEntity(from: $0) }
        } catch {
            logger.error("Error fetching shoes, \(error).")
        }
        
        return []
    }
}

// MARK: - WidgetConfigurationIntent

struct SelectShoeIntent: WidgetConfigurationIntent {
    
    static var title: LocalizedStringResource = "Select Shoe"
    static var description: IntentDescription = IntentDescription("Selects the shoe to display stats for.")
    
    @Parameter(title: "Use Default Shoe", default: true)
    var useDefaultShoe: Bool
    
    @Parameter(title: "Shoe", default: nil)
    var shoeEntity: ShoeStatsEntity?
    
    static var parameterSummary: some ParameterSummary {
        When(\.$useDefaultShoe, .equalTo, true) {
            Summary("Use Default Shoe \(\.$useDefaultShoe)")
        } otherwise: {
            Summary("Shoe \(\.$useDefaultShoe)") {
                \.$shoeEntity
            }
        }
    }
}
