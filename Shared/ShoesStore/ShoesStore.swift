//
//  ShoesStore.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftData
import SwiftUI

typealias Shoe = ShoesSchemaV2.Shoe

actor ShoesStore {
    
    static let shared = ShoesStore()
    
    private init() {}
    
    nonisolated lazy var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Shoe.self, migrationPlan: ShoesMigrationPlan.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()
}
