//
//  Double.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 14.05.2024.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func as2DecimalsString() -> String {
        let roundedValue = String(format: "%.2f", self)
        let intValue = Int(self)
        if self - Double(intValue) == 0 {
            return "\(intValue)"
        } else {
            return "\(roundedValue)"
        }
    }
}
