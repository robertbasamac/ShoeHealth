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
    
    func addShoe(brand: String, model: String, lifespanDistance: Double, aquisitionDate: Date, isDefaultShoe: Bool) {
        let shoe = Shoe(brand: brand, model: model, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, isDefaultShoe: isDefaultShoe)
        
        if isDefaultShoe {
            if let previousDefaultShoe = shoes.first(where: { $0.isDefaultShoe} ) {
                previousDefaultShoe.isDefaultShoe = false
            }
        }
        
        modelContext.insert(shoe)
        
        fetchShoes()
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
        // return the assigned default shoe
        if let shoe = self.shoes.first(where: { $0.isDefaultShoe } ) {
            return shoe
        }
        
        // return the only available shoe
        if self.shoes.count == 1, let shoe = self.shoes.first {
            return shoe
        }
        
        return nil
    }
}
