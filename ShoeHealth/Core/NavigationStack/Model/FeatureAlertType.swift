//
//  FeatureAlertType.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 17.01.2025.
//

import Foundation

enum FeatureAlertType {
    
    case limitReached
    case defaultRunRestricted
    
    var title: String {
        switch self {
        case .limitReached:
            return "Shoes limit reached"
        case .defaultRunRestricted:
            return "Run Type restricted"
        }
    }
    
    var message: String {
        switch self {
        case .limitReached:
            return "You can only add up to \(StoreManager.shoesLimit) shoes as a free user. Upgrade to unlock unlimited shoes and additional features."
        case .defaultRunRestricted:
            return "You can only have 'Daily' shoes as a free user. Upgrade to unlock all run types and additional features."
        }
    }
}
