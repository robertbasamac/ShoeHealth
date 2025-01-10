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
        let modelContainer: ModelContainer
        
        let schema = Schema([Shoe.self])
        let cloudConfig: ModelConfiguration = .init()
        let localConfig: ModelConfiguration = .init(cloudKitDatabase: .none)
        
        do {
            _ = try? ModelContainer(
                for: schema,
                migrationPlan: ShoesMigrationPlan.self,
                configurations: localConfig
            )
            
            if let iCloudContainer = try? ModelContainer(
                for: schema,
                migrationPlan: ShoesMigrationPlan.self,
                configurations: cloudConfig
            ) {
                modelContainer = iCloudContainer
            } else {
                modelContainer = try ModelContainer(
                    for: schema,
                    migrationPlan: ShoesMigrationPlan.self,
                    configurations: localConfig
                )
            }
            
            return modelContainer
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }()
}
