//
//  WearCondition.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 11.07.2024.
//

enum WearCondition: Int, CaseIterable {
    
    case new      = 0
    case good
    case moderate
    case high
    case critical
    
    var name: String {
        switch self {
        case .new:
            return "New"
        case .good:
            return "Good"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        case .critical:
            return "Critical"
        }
    }
    
    var description: String {
        switch self {
        case .new:
            return "This shoe is brand new"
        case .good:
            return "This shoe is in good condition"
        case .moderate:
            return "This shoe is in moderate condition"
        case .high:
            return "This shoe is highly worn"
        case .critical:
            return "This shoe is in critical condition"
        }
    }
    
    var action: String {
        switch self {
        case .new, .good:
            return "No action needed"
        case .moderate:
            return "Monitor closely"
        case .high:
            return "Plan to replace"
        case .critical:
            return "Replace now"
        }
    }
    
    var iconName: String {
        switch self {
        case .new, .good:
            return "checkmark.seal.fill"
        case .moderate, .high, .critical:
            return "exclamationmark.octagon.fill"
        }
    }
}

