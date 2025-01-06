//
//  ShoesMigrationPlan.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 14.11.2024.
//

import SwiftData

enum ShoesMigrationPlan: SchemaMigrationPlan {
    
    static var schemas: [any VersionedSchema.Type] {
        [ShoesSchemaV1.self, ShoesSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    nonisolated(unsafe) static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: ShoesSchemaV1.self,
        toVersion: ShoesSchemaV2.self,
        willMigrate: { context in
            do {
                let v1Shoes = try context.fetch(FetchDescriptor<ShoesSchemaV1.Shoe>())
                
                for v1Shoe in v1Shoes {
                    let v2Shoe = ShoesSchemaV2.Shoe(
                        id: v1Shoe.id,
                        image: v1Shoe.image,
                        brand: v1Shoe.brand,
                        model: v1Shoe.model,
                        nickname: v1Shoe.nickname,
                        lifespanDistance: v1Shoe.lifespanDistance,
                        aquisitionDate: v1Shoe.aquisitionDate,
                        totalDistance: v1Shoe.totalDistance,
                        totalDuration: v1Shoe.totalDuration,
                        lastActivityDate: v1Shoe.lastActivityDate,
                        isRetired: v1Shoe.isRetired,
                        retireDate: v1Shoe.retireDate,
                        defaultRunTypes: v1Shoe.isDefaultShoe ? [.daily] : [],
                        workouts: v1Shoe.workouts,
                        personalBests: v1Shoe.personalBests,
                        totalRuns: v1Shoe.totalRuns
                    )
                    
                    context.insert(v2Shoe)
                    context.delete(v1Shoe)
                }
                
                try context.save()
            } catch {
                print("Error migrating, \(error.localizedDescription).")
            }
        },
        didMigrate: { context in
            print("Migrated!", context.container)
        }
    )
}
