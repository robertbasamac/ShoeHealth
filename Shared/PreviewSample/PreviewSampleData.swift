//
//  PreviewSampleData.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 27.11.2023.
//

import SwiftData
import SwiftUI

actor PreviewSampleData {

    @MainActor
    static var container: ModelContainer = {
        return try! inMemoryContainer()
    }()
    
    @MainActor
    static var emptyContainer: ModelContainer = {
        return try! emptyInMemoryContainer()
    }()

    static var inMemoryContainer: () throws -> ModelContainer = {
        let schema = Schema([Shoe.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        
        var sampleData: [any PersistentModel] {
            var samples: [any PersistentModel] = []
            
            samples.append(contentsOf: Shoe.previewShoes)
            
            return samples
        }
        
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        
        return container
    }
    
    static var emptyInMemoryContainer: () throws -> ModelContainer = {
        let schema = Schema([Shoe.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        
        return container
    }
}
