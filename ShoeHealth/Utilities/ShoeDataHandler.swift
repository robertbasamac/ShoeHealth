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

final class ShoeDataHandler {

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

    func addShoe(nickname: String, brand: String, model: String, lifespanDistance: Double, aquisitionDate: Date, isDefaultShoe: Bool, defaultRunTypes: [RunType], image: Data?) -> Shoe {
        let newShoe = Shoe(image: image, brand: brand, model: model, nickname: nickname, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, isDefaultShoe: isDefaultShoe, defaultRunTypes: defaultRunTypes)
        
        if isDefaultShoe {
            do {
                let allShoes = try modelContext.fetch(FetchDescriptor<Shoe>())
                
                for otherShoe in allShoes {
                    otherShoe.defaultRunTypes.removeAll(where: { defaultRunTypes.contains($0) })
                    if otherShoe.defaultRunTypes.isEmpty {
                        otherShoe.isDefaultShoe = false
                    }
                }
            } catch {
                logger.error("Failed to fetch shoes: \(error)")
            }
        }
        
        modelContext.insert(newShoe)
        saveContext()
        return newShoe
    }
    
    func updateShoe(shoeID: UUID, nickname: String, brand: String, model: String, isDefaultShoe: Bool, defaultRunTypes: [RunType], lifespanDistance: Double, aquisitionDate: Date, image: Data?) {
        guard let shoe = getShoe(forID: shoeID) else { return }
        
        if !brand.isEmpty {
            shoe.brand = brand
        }
        if !model.isEmpty {
            shoe.model = model
        }
        if !nickname.isEmpty {
            shoe.nickname = nickname
        }
        
        shoe.image = image
        shoe.aquisitionDate = aquisitionDate
        shoe.lifespanDistance = lifespanDistance
        shoe.isDefaultShoe = isDefaultShoe
        shoe.defaultRunTypes = isDefaultShoe ? defaultRunTypes : []
        
        saveContext()
    }
    
    func deleteShoe(_ shoe: Shoe) {
        modelContext.delete(shoe)
        saveContext()
    }
    
    func setAsDefaultShoe(_ shoe: Shoe, for runTypes: [RunType], append: Bool) {
        do {
            let allShoes = try modelContext.fetch(FetchDescriptor<Shoe>())
            
            for otherShoe in allShoes {
                otherShoe.defaultRunTypes.removeAll(where: { runTypes.contains($0) })
                
                if otherShoe.defaultRunTypes.isEmpty {
                    otherShoe.isDefaultShoe = false
                }
            }
            
            if append {
                shoe.defaultRunTypes.append(contentsOf: runTypes)
            } else {
                shoe.defaultRunTypes = runTypes
            }
            
            shoe.isDefaultShoe = true
            shoe.isRetired = false
            
            saveContext()
        } catch {
            logger.error("Failed to fetch shoes: \(error)")
        }
    }
    
    func retireShoe(_ shoe: Shoe) {
        shoe.isRetired.toggle()
        shoe.retireDate = shoe.isRetired ? Date() : nil
        
        if shoe.isDefaultShoe && !shoe.defaultRunTypes.isEmpty && shoe.isRetired {
            shoe.isDefaultShoe = false
            shoe.defaultRunTypes = []
        }
        
        saveContext()
    }

    private func saveContext() {
        do {
            try modelContext.save()
            logger.debug("Context saved successfully.")
        } catch {
            logger.error("Saving context failed, \(error.localizedDescription)")
        }
    }
}
