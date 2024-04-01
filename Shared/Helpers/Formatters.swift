//
//  Formatters.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 06.12.2023.
//

import Foundation

var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .medium
    
    return formatter
}

var dateTimeFormatter: DateFormatter {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    
    return formatter
}

var dateComponentsFormatter: DateComponentsFormatter {
    let formatter = DateComponentsFormatter()
    
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .default
    formatter.allowedUnits = [.day, .hour, .minute, .second]
    
    return formatter
}

var distanceFormatter: LengthFormatter {
    let formatter = LengthFormatter()
    
    formatter.unitStyle = .short
    formatter.numberFormatter.minimumFractionDigits = 0
    formatter.numberFormatter.maximumFractionDigits = 2
    
    return formatter
}

var percentageFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .percent
    formatter.minimumIntegerDigits = 1
    formatter.maximumIntegerDigits = 2
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 2
    
    return formatter
}
