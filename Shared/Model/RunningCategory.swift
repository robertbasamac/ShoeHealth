//
//  RunningCategory.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 20.05.2024.
//

import Foundation

enum RunningCategory: String, CaseIterable, Codable {
    case fiveK = "5k"
    case tenK = "10k"
    case halfMarathon = "1/2 Marathon"
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
            return "5k"
        case .tenK:
            return "10K"
        case .halfMarathon:
            return "21k"
        case .marathon:
            return "42k"
        }
    }
}
