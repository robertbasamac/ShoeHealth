//
//  ShoeFilterType.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 25.01.2024.
//

enum ShoeCategory: String, Identifiable, CaseIterable {
    
    var id: Self { self }

    case all     = "All"
    case active  = "Active"
    case retired = "Retired"
    
    var title: String {
        switch self {
        case .all:     return "Shoes"
        case .active:  return "Active Shoes"
        case .retired: return "Retired Shoes"
        }
    }
}

// MARK: - Equatable

extension ShoeCategory: Equatable {
    static func == (lhs: ShoeCategory, rhs: ShoeCategory) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
