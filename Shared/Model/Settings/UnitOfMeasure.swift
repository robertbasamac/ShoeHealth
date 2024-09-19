//
//  UnitOfMeasure.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.08.2024.
//

import Foundation
import HealthKit

enum UnitOfMeasure: String {
    
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
            500.0...1200.0
        case .imperial:
            300.0...800.0
        }
    }
}
