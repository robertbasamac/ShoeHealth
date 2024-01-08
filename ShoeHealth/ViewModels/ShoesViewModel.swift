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
    
    func addShoe(nickname: String, brand: String, model: String, lifespanDistance: Double, aquisitionDate: Date, isDefaultShoe: Bool) {
        let shoe = Shoe(nickname: nickname, brand: brand, model: model, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, isDefaultShoe: isDefaultShoe)
        
        if isDefaultShoe, let previousDefaultShoe = shoes.first(where: { $0.isDefaultShoe} ) {
            previousDefaultShoe.isDefaultShoe = false
        }
        
        if shoes.isEmpty {
            shoe.isDefaultShoe = true
        }
        
        modelContext.insert(shoe)
        
        fetchShoes()
    }
    
    func setAsDefaultShoe(_ shoe: Shoe) {
        if let defaultShoe = getDefaultShoe() {
            defaultShoe.isDefaultShoe = false
        }
        
        shoe.isDefaultShoe = true
        
        fetchShoes()
    }
    
    func deleteShoe(at offsets: IndexSet) {
        withAnimation {
            offsets.map { self.shoes[$0] }.forEach { shoe in
                modelContext.delete(shoe)
            }
        }
    }
    
    func deleteShoe(_ shoe: Shoe) {
        modelContext.delete(shoe)
        fetchShoes()
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
        guard let shoe = self.shoes.first(where: { $0.isDefaultShoe } ) else { return nil }
        return shoe
    }
}
