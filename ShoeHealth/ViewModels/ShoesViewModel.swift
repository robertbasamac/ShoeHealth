//
//  ShoesViewModel.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 12.12.2023.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class ShoesViewModel {
    
    private var modelContext: ModelContext
    
    var shoes: [Shoe] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchShoes()
    }
    
    func addShoe(brand: String, model: String, lifespanDistance: Double, aquisitionDate: Date) {
        let shoe = Shoe(brand: brand, model: model, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate)
        shoes.append(shoe)
        modelContext.insert(shoe)
    }
    
    func deleteShoe(at offsets: IndexSet) {
        withAnimation {
            offsets.map { self.shoes[$0] }.forEach { shoe in
                modelContext.delete(shoe)
            }
        }
    }
    
    func fetchShoes() {
        do {
            let descriptor = FetchDescriptor<Shoe>(sortBy: [SortDescriptor(\.brand, order: .forward)])
            self.shoes = try modelContext.fetch(descriptor)
        } catch {
            print("Fetching shoes failed, \(error.localizedDescription)")
        }
    }
    
    func getDefaultShoe() -> Shoe? {
        if let shoe = self.shoes.first {
            return shoe
        }
        
        return nil
    }
}
