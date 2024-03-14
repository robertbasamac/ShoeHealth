//
//  Shoe.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Shoe {
    var id: UUID
    
    @Attribute(.unique) var nickname: String
    @Attribute(.externalStorage) var image: Data?
    var brand: String
    var model: String
    var lifespanDistance: Double
    var currentDistance: Double
    var aquisitionDate: Date
    var retireDate: Date?
    var lastActivityDate: Date?
    var retired: Bool
    var isDefaultShoe: Bool
    var workouts: [UUID] = []
    
    init(id: UUID = .init(),
         nickname: String,
         brand: String,
         model: String,
         lifespanDistance: Double,
         currentDistance: Double = 0,
         aquisitionDate: Date,
         isDefaultShoe: Bool = false,
         image: Data? = nil) {
        self.id = id
        self.nickname = nickname
        self.brand = brand
        self.model = model
        self.lifespanDistance = lifespanDistance
        self.currentDistance = currentDistance
        self.aquisitionDate = aquisitionDate
        self.retireDate = nil
        self.lastActivityDate = nil
        self.retired = false
        self.isDefaultShoe = isDefaultShoe
        self.image = image
    }
}

// MARK: - Transient properties

extension Shoe {
    
    @Transient
    var wearPercentage: Double {
        return currentDistance / lifespanDistance
    }
    
    @Transient
    var wearPercentageAsString: String {
        return percentageFormatter.string(from: NSNumber(value: currentDistance / lifespanDistance)) ?? "0"
    }
    
    @Transient
    var wearColor: Color {
        let wear = self.currentDistance / self.lifespanDistance
        if wear < 0.7 {
            return .green
        } else if wear < 0.8 {
            return .yellow
        } else if wear < 0.9 {
            return .orange
        } else {
            return .red
        }
    }
}


// MARK: - Preview data

extension Shoe {
    
    static var previewShoe: Shoe {
        Shoe(nickname: "My love", brand: "Nike", model: "Pegasus Turbo Next Nature", lifespanDistance: 500, currentDistance: 350, aquisitionDate: Date.now, isDefaultShoe: true)
    }
    
    static var previewShoes: [Shoe] {
        [
            Shoe(nickname: "Shoey", brand: "Nike", model: "Pegasus 40", lifespanDistance: 600, aquisitionDate: Date.now, isDefaultShoe: false),
            Shoe(nickname: "Carl", brand: "Nike", model: "Pegasus Turbo Next Nature", lifespanDistance: 500, currentDistance: 250, aquisitionDate: Date.now, isDefaultShoe: true),
            Shoe(nickname: "Fasty", brand: "Nike", model: "Alphafly 3", lifespanDistance: 800, currentDistance: 280.25, aquisitionDate: Date.now, isDefaultShoe: false),
            Shoe(nickname: "5k love", brand: "Nike", model: "Streakfly 2", lifespanDistance: 800, currentDistance: 715.42, aquisitionDate: Date.now, isDefaultShoe: false)
        ]
    }
}
