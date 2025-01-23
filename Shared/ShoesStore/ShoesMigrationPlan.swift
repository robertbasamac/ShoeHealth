//
//  ShoesMigrationPlan.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 14.11.2024.
//

@preconcurrency import SwiftData

enum ShoesMigrationPlan: SchemaMigrationPlan {
    
    static var schemas: [any VersionedSchema.Type] {
        [ShoesSchemaV1.self, ShoesSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: ShoesSchemaV1.self,
        toVersion: ShoesSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            let shoes = try? context.fetch(FetchDescriptor<ShoesSchemaV2.Shoe>())
            
            shoes?.forEach { shoe in
                shoe.defaultRunTypes = shoe.isDefaultShoe ? [.daily] : []
            }
            
            try? context.save()
        }
    )
}
