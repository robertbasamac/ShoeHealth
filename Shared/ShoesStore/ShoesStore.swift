//
//  ShoesStore.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 05.03.2024.
//

import SwiftData
import SwiftUI

typealias Shoe = ShoesSchemaV3.Shoe

actor ShoesStore {

    // MARK: - Public singleton
    // Default flavor differs for app vs widget via compile flag
    static let shared = ShoesStore(container: ShoesStore.makeContainerDefault())

    // MARK: - Storage
    nonisolated let container: ModelContainer
    nonisolated var modelContainer: ModelContainer { container }

    // MARK: - Init
    init(container: ModelContainer) { self.container = container }

    // MARK: - Flavors
    enum Flavor {
        case appPrimaryCloudBacked   // App: try CloudKit in App Group, fallback local in App Group
        case widgetReadOnly          // Widget: read-only, no CloudKit, App Group storage
        case previewInMemory         // Previews/Tests: in-memory, read-only
    }

    // Centralize the App Group ID here to avoid cross-module dependencies
    private static let appGroupID = "group.com.robertbasamac.ShoeHealth"

    // Decide a sensible default for each target
    static func makeContainerDefault() -> ModelContainer {
        #if WIDGET_EXTENSION
        return makeContainer(.widgetReadOnly)
        #else
        return makeContainer(.appPrimaryCloudBacked)
        #endif
    }

    // MARK: - Factory
    
    static func makeContainer(_ flavor: Flavor) -> ModelContainer {
        let schema = Schema([Shoe.self])
        let migration = ShoesMigrationPlan.self

        switch flavor {
        case .widgetReadOnly:
            // Read-only DB in shared App Group, no CloudKit
            let cfg = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: false,
                groupContainer: .identifier(appGroupID),
                cloudKitDatabase: .none
            )
            return tryOrFallback(schema: schema, migration: migration, config: cfg, readOnlyFallback: true)

        case .previewInMemory:
            return try! ModelContainer(
                for: schema,
                migrationPlan: migration,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: false)
            )

        case .appPrimaryCloudBacked:
            // Warm up local migration first (avoids crash when moving between versions)
            _ = try? ModelContainer(
                for: schema,
                migrationPlan: migration,
                configurations: ModelConfiguration(
                    groupContainer: .identifier(appGroupID),
                    cloudKitDatabase: .none
                )
            )

            // Prefer CloudKit in the same App Group folder (so app & widget can share if desired)
            if let cloudContainer = try? ModelContainer(
                for: schema,
                migrationPlan: migration,
                configurations: ModelConfiguration(
                    groupContainer: .identifier(appGroupID),
                    cloudKitDatabase: .automatic
                )
            ) {
                return cloudContainer
            }
        }
        
        // Fallback to local store in App Group if CloudKit not available
        return tryOrFallback(
            schema: schema,
            migration: migration,
            config: ModelConfiguration(
                groupContainer: .identifier(appGroupID),
                cloudKitDatabase: .none
            ),
            readOnlyFallback: false
        )
    }

    // MARK: - Helpers
    
    private static func tryOrFallback(
        schema: Schema,
        migration: any SchemaMigrationPlan.Type,
        config: ModelConfiguration,
        readOnlyFallback: Bool
    ) -> ModelContainer {
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: migration,
                configurations: config
            )
        } catch {
            // Avoid hard crash; keep the UI rendering (especially in widgets)
            print("SwiftData container init failed: \(error)")
            return try! ModelContainer(
                for: schema,
                migrationPlan: migration,
                configurations: ModelConfiguration(
                    isStoredInMemoryOnly: true,
                    allowsSave: !readOnlyFallback // widget stays read-only
                )
            )
        }
    }
}
