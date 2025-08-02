//
//  ShoesStoreActor.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 02.07.2025.
//

import SwiftData
import SwiftUI

@ModelActor
actor ShoesStoreActor {

    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
    }

    func fetchAllShoes() async throws -> [Shoe] {
        let context = ModelContext(modelContainer)
        let fetchDescriptor = FetchDescriptor<Shoe>()
        return try context.fetch(fetchDescriptor)
    }

    func fetchShoe(with id: UUID) async throws -> Shoe? {
        let context = ModelContext(modelContainer)
        let fetchDescriptor = FetchDescriptor<Shoe>(predicate: #Predicate { $0.id == id })
        return try context.fetch(fetchDescriptor).first
    }

    func addShoe(_ shoe: Shoe) async throws {
        let context = ModelContext(modelContainer)
        context.insert(shoe)
        try context.save()
    }

    func updateShoe(_ shoe: Shoe) async throws {
        let context = ModelContext(modelContainer)
        // Fă update după nevoie pe entitate
        try context.save()
    }

    func deleteShoe(_ shoe: Shoe) async throws {
        let context = ModelContext(modelContainer)
        context.delete(shoe)
        try context.save()
    }
}
