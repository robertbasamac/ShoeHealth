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
