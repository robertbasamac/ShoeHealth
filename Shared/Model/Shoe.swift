//
//  Shoe.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Shoe {
    var id: UUID
    
    @Attribute(.unique) var nickname: String
    @Attribute(.externalStorage) var image: Data?
    var brand: String
    var model: String
    var lifespanDistance: Double
    var totalDistance: Double
    var aquisitionDate: Date
    var retireDate: Date?
    var lastActivityDate: Date?
    var isRetired: Bool
    var isDefaultShoe: Bool
    var workouts: [UUID] = []
    var personalBests: [RunningCategory: PersonalBest?] = [:]
    var totalRuns: [RunningCategory: Int] = [:]
    var totalDuration: Double = 0
    
    init(id: UUID = .init(),
         nickname: String,
         brand: String,
         model: String,
         lifespanDistance: Double,
         currentDistance: Double = 0,
         aquisitionDate: Date,
         isDefaultShoe: Bool = false,
         image: Data? = nil) {
        self.id = id
        self.nickname = nickname
        self.brand = brand
        self.model = model
        self.lifespanDistance = lifespanDistance
        self.totalDistance = currentDistance
        self.aquisitionDate = aquisitionDate
        self.retireDate = nil
        self.lastActivityDate = nil
        self.isRetired = false
        self.isDefaultShoe = isDefaultShoe
        self.image = image
    }
}

// MARK: - Transient properties

extension Shoe {
    
    var wearPercentage: Double {
        return totalDistance / lifespanDistance
    }
    
    var wearPercentageAsString: String {
        return percentageFormatter.string(from: NSNumber(value: totalDistance / lifespanDistance)) ?? "0"
    }
    
    var wearColor: Color {
        let wear = self.totalDistance / self.lifespanDistance
        if wear < 0.7 {
            return .green
        } else if wear < 0.8 {
            return .yellow
        } else if wear < 0.9 {
            return .orange
        } else {
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
    
    func formattedPersonalBest(for category: RunningCategory) -> String {
        return formatDuration(personalBests[category]??.time)
    }
    
    func formatDuration(_ duration: TimeInterval?) -> String {
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
}


// MARK: - Preview data

extension Shoe {
    
    static var previewShoe: Shoe {
        Shoe(nickname: "Turbo", brand: "Nike", model: "Pegasus Turbo Next Nature", lifespanDistance: 500, currentDistance: 350, aquisitionDate: Date.now, isDefaultShoe: true, image: UIImage(named: "pegasus")?.pngData())
    }
    
    static var previewShoes: [Shoe] {
        [
            Shoe(nickname: "Shoey", brand: "Nike", model: "Pegasus 40", lifespanDistance: 600, aquisitionDate: Date.now, isDefaultShoe: false, image: UIImage(named: "pegasus")?.pngData()),
            Shoe(nickname: "Carl", brand: "Nike", model: "Pegasus Turbo Next Nature", lifespanDistance: 500, currentDistance: 250, aquisitionDate: Date.now, isDefaultShoe: true, image: UIImage(named: "pegasus")?.pngData()),
            Shoe(nickname: "Fasty", brand: "Nike", model: "Alphafly 3", lifespanDistance: 800, currentDistance: 280.25, aquisitionDate: Date.now, isDefaultShoe: false),
            Shoe(nickname: "5k love", brand: "Nike", model: "Streakfly 2", lifespanDistance: 800, currentDistance: 715.42, aquisitionDate: Date.now, isDefaultShoe: false)
        ]
    }
}
