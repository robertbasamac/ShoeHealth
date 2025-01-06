//
//  ShoesStore.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftData
import SwiftUI

typealias Shoe = ShoesSchemaV2.Shoe

final class ShoesStore {
    
    static let container = {
        let container: ModelContainer
        
        do {
            container = try ModelContainer(for: Shoe.self, migrationPlan: ShoesMigrationPlan.self)
        } catch {
            fatalError("Failed to create ModelContainer for Shoe: \(error)")
        }
        
        return container
    }()
}
