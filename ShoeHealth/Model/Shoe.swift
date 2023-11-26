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
    
    init(id: UUID = .init(),
         brand: String,
         model: String,
         lifespanDistance: Double,
         currentDistance: Double = 0,
         aquisitionDate: Date,
         retireDate: Date? = nil,
         retired: Bool = false) {
        self.id = id
        self.brand = brand
        self.model = model
        self.lifespanDistance = lifespanDistance
        self.currentDistance = currentDistance
        self.aquisitionDate = aquisitionDate
        self.retireDate = retireDate
        self.retired = retired
    }
}
