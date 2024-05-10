//
//  HKWorkout+Statistics.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 25.11.2023.
//

import Foundation
import HealthKit

extension HKWorkout {
    
    var startDateAsString: String {
        return dateFormatter.string(from: self.startDate)
    }
    
    var endDateAsString: String {
        return dateFormatter.string(from: self.endDate)
    }
    
    var startTimeAsString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self.startDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var endTimeAsString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self.endDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var durationAsString: String {
        let duration = self.duration
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))

        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    func totalDistance(unitPrefix unit: HKMetricPrefix = .kilo) -> Double {
        guard let distance = self.statistics(for: .init(.distanceWalkingRunning))?.sumQuantity() else { return 0 }
        
        return distance.doubleValue(for: HKUnit.meterUnit(with: unit))
    }
    
    var averagePower: Double {
        guard let averagePower = self.statistics(for: .init(.runningPower))?.averageQuantity() else { return 0 }
        
        return floor(averagePower.doubleValue(for: HKUnit.watt()))
    }
    
    var activeKilocalories: Double {
        guard let activeKCal = self.statistics(for: .init(.activeEnergyBurned))?.sumQuantity() else { return 0 }
        
        return activeKCal.doubleValue(for: HKUnit.kilocalorie())
    }
    
    var averagePace: (minutes: Int, seconds: Int) {
        let duration = self.duration
        
        let distance = self.totalDistance()
        let durationMinutes = duration / 60
        
        let paceMinutes = durationMinutes / distance
        
        let minutes = Int(paceMinutes)
        let seconds = Int((paceMinutes - Double(minutes)) * 60)
        
        return (minutes, seconds)
    }
    
    var averageHeartRate: Double {
        guard let averageHR = self.statistics(for: .init(.heartRate))?.averageQuantity() else { return 0 }
        
        return averageHR.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
    }
    
    var averageCadence: Double {
        guard let stepCount = self.statistics(for: .init(.stepCount))?.sumQuantity() else { return 0 }
        
        let averageCadence = stepCount.doubleValue(for: HKUnit.count()) / self.duration * 60
        
        return averageCadence
    }
}
