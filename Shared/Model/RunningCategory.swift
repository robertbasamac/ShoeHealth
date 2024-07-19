//
//  RunningCategory.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 20.05.2024.
//

enum RunningCategory: String, CaseIterable, Codable {
    
    case fiveK = "5K"
    case tenK = "10K"
    case halfMarathon = "Half-Marathon"
    case marathon = "Marathon"

    var distance: Double {
        switch self {
        case .fiveK:
            return 5000
        case .tenK:
            return 10000
        case .halfMarathon:
            return 21097.5
        case .marathon:
            return 42195
        }
    }
    
    var shortTitle: String {
        switch self {
        case .fiveK:
            return "5K"
        case .tenK:
            return "10K"
        case .halfMarathon:
            return "21K"
        case .marathon:
            return "42K"
        }
    }
}
