//
//  RunType.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.12.2024.
//

import AppIntents

enum RunType: String, CaseIterable, Codable, Hashable, AppEnum {
    
    case daily
    case long
    case tempo
    case race
    case trail
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Run Type"
    }
    
    static var caseDisplayRepresentations: [RunType : DisplayRepresentation] {
        [
            .daily: "Daily Runs",
            .long: "Long Runs",
            .tempo: "Tempo Runs",
            .race: "Recovery Runs",
            .trail: "Trail Runs"
        ]
    }
}
