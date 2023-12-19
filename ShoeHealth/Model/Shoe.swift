//
//  Shoe.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import Foundation
import SwiftData

@Model
final class Shoe {
    var id: UUID
    var brand: String
    var model: String
    var lifespanDistance: Double
    var currentDistance: Double
    var aquisitionDate: Date
    var retireDate: Date?
    var retired: Bool
    var isDefaultShoe: Bool
    var workouts: [UUID] = []
    
    init(id: UUID = .init(),
         brand: String,
         model: String,
         lifespanDistance: Double,
         currentDistance: Double = 0,
         aquisitionDate: Date,
         isDefaultShoe: Bool = false) {
        self.id = id
        self.brand = brand
        self.model = model
        self.lifespanDistance = lifespanDistance
        self.currentDistance = currentDistance
        self.aquisitionDate = aquisitionDate
        self.retireDate = nil
        self.retired = false
        self.isDefaultShoe = isDefaultShoe
    }
}

extension Shoe {
    @Transient
    var wearPercentageAsString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 2
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: currentDistance / lifespanDistance)) ?? "0.0"
    }
}


// MARK: - Preview data
extension Shoe {
    static var previewShoe: Shoe {
        Shoe(brand: "Nike", model: "Pegasus Turbo Next Nature", lifespanDistance: 500, currentDistance: 250, aquisitionDate: Date.now, isDefaultShoe: true)
    }
    
    static var previewShoes: [Shoe] {
        [
            Shoe(brand: "Nike", model: "Pegasus 40", lifespanDistance: 600, currentDistance: 400, aquisitionDate: Date.now, isDefaultShoe: false),
            Shoe(brand: "Nike", model: "Pegasus Turbo Next Nature", lifespanDistance: 500, currentDistance: 250, aquisitionDate: Date.now, isDefaultShoe: true),
            Shoe(brand: "Nike", model: "Alphafly 3", lifespanDistance: 800, currentDistance: 703.53, aquisitionDate: Date.now, isDefaultShoe: false),
            Shoe(brand: "Nike", model: "Streakfly 2", lifespanDistance: 800, currentDistance: 250, aquisitionDate: Date.now, isDefaultShoe: false)
        ]
    }
}
