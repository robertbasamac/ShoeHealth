//
//  ShoeFilterType.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 25.01.2024.
//

enum ShoeFilterType: String, Identifiable, CaseIterable {
    var id: Self { self }

    case all     = "All Shoes"
    case active  = "Active Shoes"
    case retired = "Retired Shoes"
}
