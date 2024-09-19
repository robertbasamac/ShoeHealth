//
//  PresetTime.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.09.2024.
//

import Foundation

// MARK: - PresetTime struct

enum PresetTime: CaseIterable {
    
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case custom(value: Int, unit: TimeUnit)
    
    var duration: TimeDuration {
        switch self {
        case .fiveMinutes:
            return TimeDuration(value: 5, unit: .minutes)
        case .tenMinutes:
            return TimeDuration(value: 10, unit: .minutes)
        case .fifteenMinutes:
            return TimeDuration(value: 15, unit: .minutes)
        case .thirtyMinutes:
            return TimeDuration(value: 30, unit: .minutes)
        case .oneHour:
            return TimeDuration(value: 1, unit: .hour)
        case .custom(let value, let unit):
            return TimeDuration(value: value, unit: TimeUnit.unit(for: value, unitType: unit))
        }
    }
    
    static var allCases: [PresetTime] {
        return [.fiveMinutes, .tenMinutes, .fifteenMinutes, .thirtyMinutes, .oneHour]
    }
    
    var encodedString: String {
        switch self {
        case .fiveMinutes:
            return "fiveMinutes"
        case .tenMinutes:
            return "tenMinutes"
        case .fifteenMinutes:
            return "fifteenMinutes"
        case .thirtyMinutes:
            return "thirtyMinutes"
        case .oneHour:
            return "oneHour"
        case .custom(let value, let unit):
            return "custom:\(value):\(unit.rawValue)"
        }
    }
    
    init?(from string: String) {
        let components = string.split(separator: ":")
        
        switch components[0] {
        case "fiveMinutes":
            self = .fiveMinutes
        case "tenMinutes":
            self = .tenMinutes
        case "fifteenMinutes":
            self = .fifteenMinutes
        case "thirtyMinutes":
            self = .thirtyMinutes
        case "oneHour":
            self = .oneHour
        case "custom":
            if components.count == 3,
               let value = Int(components[1]),
               let unit = TimeUnit(rawValue: String(components[2])) {
                self = .custom(value: value, unit: unit)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

// MARK: - Hashable

extension PresetTime: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .fiveMinutes:
            hasher.combine(0)
        case .tenMinutes:
            hasher.combine(1)
        case .fifteenMinutes:
            hasher.combine(2)
        case .thirtyMinutes:
            hasher.combine(3)
        case .oneHour:
            hasher.combine(4)
        case .custom(let value, let unit):
            hasher.combine(5)
            hasher.combine(value)
            hasher.combine(unit)
        }
    }
    
    static func == (lhs: PresetTime, rhs: PresetTime) -> Bool {
        switch (lhs, rhs) {
        case (.fiveMinutes, .fiveMinutes),
            (.tenMinutes, .tenMinutes),
            (.fifteenMinutes, .fifteenMinutes),
            (.thirtyMinutes, .thirtyMinutes),
            (.oneHour, .oneHour):
            return true
        case (.custom(let value1, let unit1), .custom(let value2, let unit2)):
            return value1 == value2 && unit1 == unit2
        default:
            return false
        }
    }
}

// MARK: - TimeDuration struct

struct TimeDuration {
    
    let value: Int
    let unit: TimeUnit
}

// MARK: - TimeUnit enum

enum TimeUnit: String {
    
    case minute, minutes
    case hour, hours
    case day, days
    
    static func unit(for value: Int, unitType: TimeUnit) -> Self {
        switch unitType {
        case .minute, .minutes:
            return value == 1 ? TimeUnit.minute : TimeUnit.minutes
        case .hour, .hours:
            return value == 1 ? TimeUnit.hour : TimeUnit.hours
        case .day, .days:
            return value == 1 ? TimeUnit.day : TimeUnit.days
        }
    }
}
