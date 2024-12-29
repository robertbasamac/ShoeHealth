//
//  ShoesMigrationPlan.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 14.11.2024.
//

import SwiftData

enum ShoesMigrationPlan: SchemaMigrationPlan {
    
    static var schemas: [any VersionedSchema.Type] {
        [ShoesSchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        []
    }
}
