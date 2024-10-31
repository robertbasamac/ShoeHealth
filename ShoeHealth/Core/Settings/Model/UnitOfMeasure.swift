//
//  UnitOfMeasure.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.08.2024.
//

import Foundation
import HealthKit

enum UnitOfMeasure: String, CaseIterable {
    
    case metric = "Metric"
    case imperial = "Imperial"
    
    var unit: HKUnit {
        switch self {
        case .metric:
            .meterUnit(with: .kilo)
        case .imperial:
            .mile()
        }
    }
    
    var symbol: String {
        switch self {
        case .metric:
            "KM"
        case .imperial:
            "MI"
        }
    }
    
    var range: ClosedRange<Double> {
        switch self {
        case .metric:
            300...1000.0
        case .imperial:
            200...600.0
        }
    }
    
    static func convert(distance: Double, toUnit targetUnit: UnitOfMeasure) -> Double {
        var convertedDistance: Double
        let targetRange = targetUnit.range
        
        if targetUnit == .metric {
            convertedDistance = distance * 1.60934 // miles to km
        } else {
            convertedDistance = distance / 1.60934 // km to miles
        }
        
        if convertedDistance < targetRange.lowerBound {
            convertedDistance = targetRange.lowerBound
        } else if convertedDistance > targetRange.upperBound {
            convertedDistance = targetRange.upperBound
        }
        
        return convertedDistance.roundedToNearest50()
    }
}
