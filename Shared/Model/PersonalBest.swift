//
//  PersonalBest.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.05.2024.
//

import Foundation

struct PersonalBest: Codable {
    var time: TimeInterval
    var workoutID: UUID
    
    init(time: TimeInterval, workoutID: UUID) {
        self.time = time
        self.workoutID = workoutID
    }
}
