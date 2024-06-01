//
//  HKWorkout+Identifiable.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 27.11.2023.
//

import Foundation
import HealthKit

extension HKWorkout: Identifiable {
    
    public var id: UUID {
        self.uuid
    }
}
