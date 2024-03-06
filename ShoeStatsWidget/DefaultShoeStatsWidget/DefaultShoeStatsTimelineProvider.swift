//
//  DefaultShoeStatsTimelineProvider.swift
//  ShoeStatsWidgetExtension
//
//  Created by Robert Basamac on 06.03.2024.
//

import Foundation
import WidgetKit
import SwiftData

struct DefaultShoeStatsTimelineProvider: TimelineProvider {
    let modelContext = ModelContext(ShoesStore.container)
    
    typealias Entry = DefaultShoeWidgetEntry
    
    @MainActor
    func placeholder(in context: Context) -> Entry {
        var fetchDescriptor = FetchDescriptor<Shoe>()
        
        fetchDescriptor.predicate = #Predicate<Shoe> { $0.isDefaultShoe }
        if let shoes = try? modelContext.fetch(fetchDescriptor) {
            if let defaultShoe = shoes.first {
                let newEntry = Entry(date: .now,
                                     brand: defaultShoe.brand,
                                     model: defaultShoe.model,
                                     lifespanDistance: defaultShoe.lifespanDistance,
                                     currentDistance: defaultShoe.currentDistance,
                                     aquisitionDate: defaultShoe.aquisitionDate,
                                     wearPercentage: defaultShoe.wearPercentage,
                                     wearPercentageAsString: defaultShoe.wearPercentageAsString,
                                     wearColor: defaultShoe.wearColor)
                
                return newEntry
            }
        }
        
        let newEntry = Entry(date: .now,
                             brand: "No brand",
                             model: "No model", lifespanDistance: 0.0,
                             currentDistance: 0.0,
                             aquisitionDate: .now,
                             wearPercentage: 0.0,
                             wearPercentageAsString: "0.0",
                             wearColor: .green)
        
        return newEntry
    }
    
    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        Task {
            var fetchDescriptor = FetchDescriptor<Shoe>()
            fetchDescriptor.predicate = #Predicate<Shoe> { $0.isDefaultShoe }
            
            if let shoes = try? modelContext.fetch(fetchDescriptor) {
                if let defaultShoe = shoes.first {
                    let newEntry = Entry(date: .now,
                                               brand: defaultShoe.brand,
                                               model: defaultShoe.model,
                                               lifespanDistance: defaultShoe.lifespanDistance,
                                               currentDistance: defaultShoe.currentDistance,
                                               aquisitionDate: defaultShoe.aquisitionDate,
                                               wearPercentage: defaultShoe.wearPercentage,
                                               wearPercentageAsString: defaultShoe.wearPercentageAsString,
                                               wearColor: defaultShoe.wearColor)
                    
                    completion(newEntry)
                    return
                }
            }
            
            let newEntry = Entry(date: .now,
                                       brand: "No brand",
                                       model: "No model", lifespanDistance: 0.0,
                                       currentDistance: 0.0,
                                       aquisitionDate: .now,
                                       wearPercentage: 0.0,
                                       wearPercentageAsString: "0.0",
                                       wearColor: .green)
            
            completion(newEntry)
        }
    }
    
    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var fetchDescriptor = FetchDescriptor<Shoe>()
            fetchDescriptor.predicate = #Predicate<Shoe> { $0.isDefaultShoe }
            
            if let shoes = try? modelContext.fetch(fetchDescriptor) {
                if let defaultShoe = shoes.first {
                    let newEntry = Entry(date: .now,
                                               brand: defaultShoe.brand,
                                               model: defaultShoe.model,
                                               lifespanDistance: defaultShoe.lifespanDistance,
                                               currentDistance: defaultShoe.currentDistance,
                                               aquisitionDate: defaultShoe.aquisitionDate,
                                               wearPercentage: defaultShoe.wearPercentage,
                                               wearPercentageAsString: defaultShoe.wearPercentageAsString,
                                               wearColor: defaultShoe.wearColor)
                    
                    let timeline = Timeline(entries: [newEntry], policy: .never)
                    completion(timeline)
                    return
                }
            }
            
            let newEntry = Entry(date: .now,
                                       brand: "No brand",
                                       model: "No model", lifespanDistance: 0.0,
                                       currentDistance: 0.0,
                                       aquisitionDate: .now,
                                       wearPercentage: 0.0,
                                       wearPercentageAsString: "0.0",
                                       wearColor: .green)
            let timeline = Timeline(entries: [newEntry], policy: .never)
            
            completion(timeline)
        }
    }
}
