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
        return (self * divisor).rounded(.up) / divisor
    }
    
    func asString(withDecimals decimals: Int) -> String {
        let format = "%.\(decimals)f"
        let roundedValue = String(format: format, self.rounded(toPlaces: decimals))
        let intValue = Int(self)
        if self - Double(intValue) == 0 {
            return "\(intValue)"
        } else {
            return "\(roundedValue)"
        }
    }
    
    func roundedToNearest50() -> Double {
        (self / 50.0).rounded() * 50.0
    }
    
    func formatAsPercentage(withDecimals decimals: Int) -> String {
        let formatter = percentageFormatter(withDecimals: decimals)
        
        let scaledValue = self * 100
        if let formattedNumber = formatter.string(from: NSNumber(value: self * 100)) {
            return "\(formattedNumber)%"
        }
        return "\(scaledValue)%"
    }
}
