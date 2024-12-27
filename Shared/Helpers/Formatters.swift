//
//  Formatters.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 06.12.2023.
//

import Foundation

/// Example Output: "Nov 29, 2024"
var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .medium
    
    return formatter
}

/// Example Output: "Nov 29, 2024 at 2:45 PM"
var dateTimeFormatter: DateFormatter {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    
    return formatter
}

/// Example Output: "1:23:45" (1 hour, 23 minutes, 45 seconds)
var dateComponentsFormatter: DateComponentsFormatter {
    let formatter = DateComponentsFormatter()
    
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .default
    formatter.allowedUnits = [.day, .hour, .minute, .second]
    
    return formatter
}

/// Example Output: "1.2 km" or "3.45 mi" depending on the locale and unit system.
var distanceFormatter: LengthFormatter {
    let formatter = LengthFormatter()
    
    formatter.unitStyle = .short
    formatter.numberFormatter.minimumFractionDigits = 0
    formatter.numberFormatter.maximumFractionDigits = 2
    
    return formatter
}

/// Example Output: "45.6%" or "100.00%"
func percentageFormatter(withDecimals decimals: Int) -> NumberFormatter {
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .decimal
    formatter.minimumIntegerDigits = 1
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = decimals
    
    return formatter
}
