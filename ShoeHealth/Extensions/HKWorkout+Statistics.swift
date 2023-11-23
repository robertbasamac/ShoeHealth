//
//  HKWorkout+Statistics.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 25.11.2023.
//

import Foundation
import HealthKit

extension HKWorkout {
    func totalDistance(unitPrefix unit: HKMetricPrefix) -> Double {
        guard let distance = self.statistics(for: .init(.distanceWalkingRunning))?.sumQuantity() else { return 0 }
        
        return distance.doubleValue(for: HKUnit.meterUnit(with: unit))
    }
}
