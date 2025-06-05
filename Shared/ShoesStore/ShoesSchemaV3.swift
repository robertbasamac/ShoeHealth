//
//  ShoesSchemaV3.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.05.2025.
//

import Foundation
import SwiftData
import SwiftUI

enum ShoesSchemaV3: @preconcurrency VersionedSchema {
    
    @MainActor static let versionIdentifier: Schema.Version = Schema.Version(3, 0, 0)
    
    static let models: [any PersistentModel.Type] = [Shoe.self]
}

// MARK: ShoeSchemaV3 Model

extension ShoesSchemaV3 {
    
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
        var isDefaultShoe: Bool = false
        var defaultRunTypes: [RunType] = []
        var suitableRunTypes: [RunType] = []
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
            isDefaultShoe: Bool = false,
            defaultRunTypes: [RunType] = [],
            suitableRunTypes: [RunType] = [],
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
            self.isDefaultShoe = isDefaultShoe
            self.defaultRunTypes = defaultRunTypes
            self.suitableRunTypes = suitableRunTypes
            self.workouts = workouts
            self.personalBests = personalBests
            self.totalRuns = totalRuns
        }
        
        // MARK: ShoeSchemaV3 Shoe - Transient properties
        
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
        
        func isDefaultShoe(for runType: RunType) -> Bool {
            return self.isDefaultShoe && self.defaultRunTypes.contains(runType)
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
        
        // MARK: ShoeSchemaV3 Shoe - Preview data
        
        static var previewShoe: Shoe {
            Shoe(
                image: UIImage(named: "ShoeHealth")?.pngData(),
                brand: "Nike",
                model: "Pegasus Turbo",
                nickname: "Next Nature",
                lifespanDistance: 500,
                totalDistance: 249.6,
                defaultRunTypes: [.daily],
                suitableRunTypes: [.daily]
            )
        }
        
        static var previewShoes: [Shoe] {
            [
                Shoe(
                    image: UIImage(named: "ShoeHealth")?.pngData(),
                    brand: "Nike",
                    model: "Pegasus 40",
                    nickname: "Shoey",
                    lifespanDistance: 600,
                    totalDistance: 249.6,
                    isDefaultShoe: true,
                    defaultRunTypes: [.daily],
                    suitableRunTypes: [.daily, .long]
                ),
                Shoe(
                    image: UIImage(named: "ShoeHealth")?.pngData(),
                    brand: "Nike",
                    model: "Pegasus Turbo Next Nature",
                    nickname: "Next Nature",
                    lifespanDistance: 500,
                    totalDistance: 300,
                    suitableRunTypes: [.daily, .tempo, .race]
                ),
                Shoe(
                    image: UIImage(named: "ShoeHealth")?.pngData(),
                    brand: "Nike",
                    model: "Streakfly 2",
                    nickname: "5k love",
                    lifespanDistance: 700,
                    totalDistance: 621.66,
                    isDefaultShoe: true,
                    defaultRunTypes: [.tempo],
                    suitableRunTypes: [.tempo, .race]
                ),
                Shoe(
                    image: UIImage(named: "ShoeHealth")?.pngData(),
                    brand: "Nike",
                    model: "Alphafly 3",
                    nickname: "Fasty",
                    lifespanDistance: 800,
                    totalDistance: 745,
                    isDefaultShoe: true,
                    defaultRunTypes: [.race],
                    suitableRunTypes: [.race, .long]
                )
            ]
        }
    }
}
