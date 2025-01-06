//
//  ShoesSchemaV2.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.12.2024.
//

import Foundation
import SwiftData
import SwiftUI

enum ShoesSchemaV2: @preconcurrency VersionedSchema {
    
    @MainActor static let versionIdentifier: Schema.Version = Schema.Version(2, 0, 0)
    
    static let models: [any PersistentModel.Type] = [Shoe.self]
}

// MARK: ShoeSchemaV2 Model

extension ShoesSchemaV2 {
    
    @Model
    final class Shoe {
        var id: UUID = UUID()
        var image: Data?
        var brand: String = ""
        var model: String = ""
        var nickname: String = ""
        var lifespanDistance: Double = 0
        var aquisitionDate: Date = Date.now
        var totalDistance: Double = 0
        var totalDuration: Double = 0
        var lastActivityDate: Date?
        var isRetired: Bool = false
        var retireDate: Date?
        var defaultRunTypes: [RunType] = []
        var workouts: [UUID] = []
        var personalBests: [RunningCategory: PersonalBest?] = [:]
        var totalRuns: [RunningCategory: Int] = [:]
        
        init(
            id: UUID = .init(),
            image: Data? = nil,
            brand: String,
            model: String,
            nickname: String,
            lifespanDistance: Double,
            aquisitionDate: Date = Date.now,
            totalDistance: Double = 0,
            totalDuration: Double = 0,
            lastActivityDate: Date? = nil,
            isRetired: Bool = false,
            retireDate: Date? = nil,
            defaultRunTypes: [RunType] = [],
            workouts: [UUID] = [],
            personalBests: [RunningCategory: PersonalBest?] = [:],
            totalRuns: [RunningCategory: Int] = [:]

        ) {
            self.id = id
            self.image = image
            self.brand = brand
            self.model = model
            self.nickname = nickname
            self.lifespanDistance = lifespanDistance
            self.aquisitionDate = aquisitionDate
            self.totalDistance = totalDistance
            self.totalDuration = totalDuration
            self.lastActivityDate = lastActivityDate
            self.isRetired = isRetired
            self.retireDate = retireDate
            self.defaultRunTypes = defaultRunTypes
            self.workouts = workouts
            self.personalBests = personalBests
            self.totalRuns = totalRuns
        }
        
        // MARK: ShoeSchemaV2 Shoe - Transient properties
        
        var wearPercentage: Double {
            return totalDistance / lifespanDistance
        }
        
        func wearPercentageAsString(withDecimals decimals: Int = 2) -> String {
            return wearPercentage.formatAsPercentage(withDecimals: decimals)
        }
        
        var wearCondition: WearCondition {
            if wearPercentage == 0 {
                return .new
            } else if wearPercentage <= 0.5 {
                return .good
            } else if wearPercentage <= 0.7 {
                return .moderate
            } else if wearPercentage <= 0.9 {
                return .high
            } else {
                return .critical
            }
        }
        
        var wearColor: Color {
            switch wearCondition {
            case .new, .good:
                return .green
            case .moderate:
                return .yellow
            case .high:
                return .orange
            case .critical:
                return .red
            }
        }
        
        var averageDuration: Double {
            guard self.workouts.count != 0 else {
                return 0
            }
            return self.totalDuration / Double(self.workouts.count)
        }
            
        
        var averageDistance: Double {
            guard self.workouts.count != 0 else {
                return 0
            }
            return self.totalDistance / Double(self.workouts.count)
        }
        
        var averagePace: (minutes: Int, seconds: Int) {
            guard self.totalDistance > 0 else { return (0, 0) }
            
            let paceInSecondsPerKilometer = self.totalDuration / self.totalDistance
            let minutes = Int(paceInSecondsPerKilometer) / 60
            let seconds = Int(paceInSecondsPerKilometer) % 60
            
            return (minutes, seconds)
        }
        
        var formattedTotalDuration: String {
            return formatDuration(self.totalDuration)
        }
        
        var formatterAverageDuration: String {
            return formatDuration(self.averageDuration)
        }
        
        func formattedPersonalBest(for category: RunningCategory) -> String {
            return formatDuration(personalBests[category]??.time)
        }
        
        private func formatDuration(_ duration: TimeInterval?) -> String {
            guard let duration = duration else { return "N/A" }
            
            let hours = Int(duration / 3600)
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        // MARK: ShoeSchemaV2 Shoe - Preview data
        
        static var previewShoe: Shoe {
            Shoe(
                image: UIImage(named: "pegasus")?.pngData(),
                brand: "Nike",
                model: "Pegasus Turbo Next Nature",
                nickname: "Carl",
                lifespanDistance: 500,
                totalDistance: 250,
                defaultRunTypes: [.daily]
            )
        }
        
        static var previewShoes: [Shoe] {
            [
                Shoe(
                    image: UIImage(named: "pegasus")?.pngData(),
                    brand: "Nike",
                    model: "Pegasus 40",
                    nickname: "Shoey",
                    lifespanDistance: 600
                ),
                Shoe(
                    image: UIImage(named: "pegasus")?.pngData(),
                    brand: "Nike",
                    model: "Pegasus Turbo Next Nature",
                    nickname: "Carl",
                    lifespanDistance: 500,
                    totalDistance: 250,
                    defaultRunTypes: [.daily]
                ),
                Shoe(
                    image: UIImage(named: "pegasus")?.pngData(),
                    brand: "Nike",
                    model: "Alphafly 3",
                    nickname: "Fasty",
                    lifespanDistance: 800,
                    totalDistance: 745,
                    defaultRunTypes: [.race]
                ),
                Shoe(
                    image: UIImage(named: "pegasus")?.pngData(),
                    brand: "Nike",
                    model: "Streakfly 2",
                    nickname: "5k love",
                    lifespanDistance: 700,
                    totalDistance: 621,
                    defaultRunTypes: [.tempo]
                )
            ]
        }
    }
}
