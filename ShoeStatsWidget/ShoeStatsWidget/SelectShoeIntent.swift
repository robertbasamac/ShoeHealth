//
//  SelectShoeIntent.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 05.03.2024.
//

import Foundation
import SwiftUI
import SwiftData
import WidgetKit
import AppIntents
import OSLog

private let logger = Logger(subsystem: "Widgets", category: "SelectShoeIntent")

// MARK: - AppEntity

struct ShoeStatsEntity: AppEntity {
    var id: UUID
    var brand: String
    var model: String
    var lifespanDistance: Double
    var currentDistance: Double
    var aquisitionDate: Date
    var wearPercentage: Double
    var wearPercentageAsString: String
    var wearColor: Color
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(brand) - \(model)")
    }
    
    init(id: UUID, brand: String, model: String, lifespanDistance: Double, currentDistance: Double, aquisitionDate: Date, wearPercentage: Double, wearPercentageAsString: String, wearColor: Color) {
        self.id = id
        self.brand = brand
        self.model = model
        self.lifespanDistance = lifespanDistance
        self.currentDistance = currentDistance
        self.aquisitionDate = aquisitionDate
        self.wearPercentage = wearPercentage
        self.wearPercentageAsString = wearPercentageAsString
        self.wearColor = wearColor
    }
    
    init(from shoe: Shoe) {
        self.id = shoe.id
        self.brand = shoe.brand
        self.model = shoe.model
        self.lifespanDistance = shoe.lifespanDistance
        self.currentDistance = shoe.currentDistance
        self.aquisitionDate = shoe.aquisitionDate
        self.wearPercentage = shoe.wearPercentage
        self.wearPercentageAsString = shoe.wearPercentageAsString
        self.wearColor = shoe.wearColor
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Shoe"
    static var defaultQuery = ShoeStatsQuery()
}

// MARK: - EntityQuery

struct ShoeStatsQuery: EntityStringQuery {
    
    func entities(matching string: String) async throws -> [ShoeStatsEntity] {
        let modelContext = ModelContext(ShoesStore.container)
        let shoes = try! modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.brand.contains(string) || $0.model.contains(string) },
                                                                  sortBy: [.init(\.brand), .init(\.model)]))
        
        return shoes.map { ShoeStatsEntity(from: $0) }
    }
    
    func entities(for identifiers: [ShoeStatsEntity.ID]) async throws -> [ShoeStatsEntity] {
        let modelContext = ModelContext(ShoesStore.container)
        let shoes = try! modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { identifiers.contains($0.id) },
                                                                  sortBy: [.init(\.brand), .init(\.model)]))
        
        return shoes.map { ShoeStatsEntity(from: $0) }
    }
    
    func suggestedEntities() async throws -> [ShoeStatsEntity] {
        let modelContext = ModelContext(ShoesStore.container)
        let shoes = try! modelContext.fetch(FetchDescriptor<Shoe>(sortBy: [.init(\.brand), .init(\.model)]))
        
        return shoes.map { ShoeStatsEntity(from: $0) }
    }
    
    func defaultResult() async -> ShoeStatsEntity? {
        let modelContext = ModelContext(ShoesStore.container)
        let shoes = try! modelContext.fetch(FetchDescriptor<Shoe>(predicate: #Predicate { $0.isDefaultShoe }))
        
        return ShoeStatsEntity(from: shoes.first!)
    }
}

// MARK: - WidgetConfigurationIntent

struct SelectShoeIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Shoe"
    static var description: IntentDescription = IntentDescription("Selects the shoe to display stats for.")
    
    @Parameter(title: "Use Default Shoe")
    var useDefaultShoe: Bool
    
    @Parameter(title: "Shoe")
    var shoeEntity: ShoeStatsEntity
    
    static var parameterSummary: some ParameterSummary {
        When(\.$useDefaultShoe, .equalTo, true) {
            Summary("Use Default Shoe \(\.$useDefaultShoe)")
        } otherwise: {
            Summary("Use Default Shoe \(\.$useDefaultShoe)") {
                \.$shoeEntity
            }
        }
    }
}
