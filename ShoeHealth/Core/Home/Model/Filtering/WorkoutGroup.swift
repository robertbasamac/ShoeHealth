//
//  WorkoutGroup.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.11.2024.
//

import Foundation
import HealthKit

struct WorkoutGroup: Identifiable {
    
    let id = UUID()
    let title: String
    let workouts: [HKWorkout]

    /// Groups workouts by their month and year based on the `endDate` and returns an array of `WorkoutGroup`.
    static func groupWorkoutsByMonthAndYear(workouts: [HKWorkout]) -> [WorkoutGroup] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        let grouped = Dictionary(grouping: workouts) { workout in
            formatter.string(from: workout.endDate)
        }
        
        return grouped
            .map { (key, workouts) in WorkoutGroup(title: key, workouts: workouts) }
            .sorted { lhs, rhs in
                guard let lhsDate = formatter.date(from: lhs.title),
                      let rhsDate = formatter.date(from: rhs.title) else {
                    return false
                }
                return lhsDate > rhsDate
            }
    }
}
