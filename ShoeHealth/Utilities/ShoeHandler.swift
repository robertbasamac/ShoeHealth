//
//  ShoeDataHandler.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 12.04.2025.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "ShoeDataHandler")

// MARK: ShoeDataHandler

final class ShoeHandler: @unchecked Sendable {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchShoes(with descriptor: FetchDescriptor<Shoe>) -> [Shoe] {
        do {
            let shoes = try modelContext.fetch(descriptor)
            
            return shoes
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
            return []
        }
    }
    
    // MARK: - Getters

    func getShoe(forID id: UUID) -> Shoe? {
        let predicate = #Predicate<Shoe> {
            $0.id == id
        }
        
        do {
            return try modelContext.fetch(FetchDescriptor(predicate: predicate)).first
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
            return nil
        }
    }

    func getShoe(ofWorkoutID workoutID: UUID) -> Shoe? {
        let predicate = #Predicate<Shoe> {
            $0.workouts.contains(workoutID)
        }
        
        do {
            return try modelContext.fetch(FetchDescriptor(predicate: predicate)).first
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
            return nil
        }
    }

    func getDefaultShoe(for runType: RunType) -> Shoe? {
        logger.debug("getDefaultShoe for \(runType.rawValue) called")
        
        let predicate = #Predicate<Shoe> {
            $0.isDefaultShoe
        }
        
        do {
            let shoes = try modelContext.fetch(FetchDescriptor(predicate: predicate))
            
            guard let shoe = shoes.first(where: { $0.defaultRunTypes.contains(runType) }) else {
                return nil
            }
            
            return shoe
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
            return nil
        }
    }
    
    func getAllDefaultShoes() -> [Shoe] {
        let predicate = #Predicate<Shoe> {
            $0.isDefaultShoe && !$0.defaultRunTypes.isEmpty
        }
        
        do {
            return try modelContext.fetch(FetchDescriptor(predicate: predicate))
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
            return []
        }
    }

    func getRecentlyUsedShoes(exclude: [UUID], prefix: Int) -> [Shoe] {
        do {
            let allShoes = try modelContext.fetch(FetchDescriptor<Shoe>())
            
            return allShoes
                .filter { !exclude.contains($0.id) && $0.lastActivityDate != nil }
                .sorted { ($0.lastActivityDate ?? .distantPast) > ($1.lastActivityDate ?? .distantPast) }
                .prefix(prefix)
                .map { $0 }
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
            return []
        }
    }

    func getRecentlyAddedShoes(exclude: [UUID], prefix: Int) -> [Shoe] {
        do {
            let allShoes = try modelContext.fetch(FetchDescriptor<Shoe>())

            return allShoes
                .filter { !exclude.contains($0.id) }
                .sorted { $0.aquisitionDate > $1.aquisitionDate }
                .prefix(prefix)
                .map { $0 }
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
            return []
        }
    }
    
    // MARK: - Handling Shoes Methods

    func addShoe(_ shoe: Shoe) {
        modelContext.insert(shoe)
        saveContext()
    }
    
    func deleteShoe(_ shoe: Shoe) {
        modelContext.delete(shoe)
        saveContext()
    }

    func saveContext() {
        do {
            try modelContext.save()
            logger.debug("Context saved successfully.")
        } catch {
            logger.error("Saving context failed, \(error.localizedDescription)")
        }
    }
}
