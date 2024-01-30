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
import HealthKit

@Observable
final class ShoesViewModel {
    
    private var modelContext: ModelContext
    
    var shoes: [Shoe] = []
    
    var searchText: String = ""
    var filterType: ShoeFilterType = .active
    var sortType: ShoeSortType = .brand
    var sortOrder: SortOrder = .forward
    
    var searchBinding: Binding<String> {
        Binding(
            get: { self.searchText },
            set: { self.searchText = $0 }
        )
    }
    var filterTypeBinding: Binding<ShoeFilterType> {
        Binding(
            get: { self.filterType },
            set: { self.filterType = $0 }
        )
    }
    var sortTypeBinding: Binding<ShoeSortType> {
        Binding(
            get: { self.sortType },
            set: { self.sortType = $0 }
        )
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchShoes()
    }
    
    // MARK: - Computed Properties
    
    var filteredShoes: [Shoe] {
        var filteredShoes: [Shoe] = []
        
        /// Filter Shoes
        switch filterType {
        case .active:
            filteredShoes = shoes.filter { !$0.retired }
        case .retired:
            filteredShoes = shoes.filter { $0.retired }
        case .all:
            filteredShoes = shoes
        }
        
        /// Sort Shoes
        switch sortType {
        case .model:
            filteredShoes.sort { sortOrder == .forward ? $0.model > $1.model : $0.model < $1.model }
        case .brand:
            filteredShoes.sort { sortOrder == .forward ? $0.brand > $1.brand : $0.brand < $1.brand }
        case .distance:
            filteredShoes.sort { sortOrder == .forward ? $0.currentDistance > $1.currentDistance : $0.currentDistance < $1.currentDistance }
        case .aquisitionDate:
            filteredShoes.sort { sortOrder == .forward ? $0.aquisitionDate > $1.aquisitionDate : $0.aquisitionDate < $1.aquisitionDate }
        }
        
        return filteredShoes
    }
    
    var searchFilteredShoes: [Shoe] {
        guard !searchText.isEmpty else {
            return filteredShoes
        }
        
        var filteredShoes: [Shoe] = []
        
        switch filterType {
        case .active:
            filteredShoes = shoes.filter { !$0.retired }
        case .retired:
            filteredShoes = shoes.filter { $0.retired }
        case .all:
            filteredShoes = shoes
        }
        
        filteredShoes = filteredShoes.filter { $0.brand.localizedCaseInsensitiveContains(searchText) || $0.model.localizedCaseInsensitiveContains(searchText) }
        filteredShoes.sort { $0.model < $1.model }

        return filteredShoes
    }
    
    // MARK: - Handling Shoes Methods
    
    func addShoe(nickname: String, brand: String, model: String, lifespanDistance: Double, aquisitionDate: Date, isDefaultShoe: Bool, image: Data?) {
        let shoe = Shoe(nickname: nickname, brand: brand, model: model, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, isDefaultShoe: isDefaultShoe, image: image)
        
        if isDefaultShoe, let previousDefaultShoe = shoes.first(where: { $0.isDefaultShoe} ) {
            previousDefaultShoe.isDefaultShoe = false
        }
        
        if shoes.isEmpty {
            shoe.isDefaultShoe = true
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
    
    func deleteShoe(_ shoe: Shoe) {
        modelContext.delete(shoe)
        fetchShoes()
    }
    
    func add(workouts: Set<UUID>, toShoe shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        shoe.workouts.append(contentsOf: workouts)
        fetchShoes()
    }
    
    func remove(workout: UUID, fromShoe shoeID: UUID) {
        guard let shoe = shoes.first(where: { $0.id == shoeID }) else { return }
        
        shoe.workouts.removeAll { $0 == workout }
        fetchShoes()
    }
        
    func fetchShoes() {
        do {
            let descriptor = FetchDescriptor<Shoe>(sortBy: [SortDescriptor(\.brand, order: .forward), SortDescriptor(\.model, order: .forward)])
            self.shoes = try modelContext.fetch(descriptor)
        } catch {
            print("Fetching shoes failed, \(error.localizedDescription)")
        }
    }
    
    // MARK: - Getters
    
    func getDefaultShoe() -> Shoe? {
        guard let shoe = self.shoes.first(where: { $0.isDefaultShoe } ) else { return nil }
        return shoe
    }
    
    // MARK: - Other Methods
    
    func setAsDefaultShoe(_ shoe: Shoe) {
        if let defaultShoe = getDefaultShoe() {
            defaultShoe.isDefaultShoe = false
        }
        
        shoe.isDefaultShoe = true
        fetchShoes()
    }
    
    func toggleSortOrder() {
        sortOrder = sortOrder == .forward ? .reverse : .forward
    }
}
