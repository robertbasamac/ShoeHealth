//
//  Shoe+Filter+Sort.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 16.01.2024.
//

import Foundation

enum ShoeFilterType: String, Identifiable, CaseIterable {
    var id: Self { self }

    case all = "All Shoes"
    case active = "Active Shoes"
    case retired = "Retired Shoes"
}

enum ShoeSortType: String, Identifiable, CaseIterable {
    var id: Self { self }

    case brand = "by Brand"
    case model = "by Model"
    case distance = "by Distance"
    case aquisitionDate = "by Aquisition Date"
}
