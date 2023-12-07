//
//  WorkoutListItem.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 27.11.2023.
//

import SwiftUI
import HealthKit

struct WorkoutListItem: View {
    var workout: HKWorkout
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(workout.endDate.formatted(date: .long, time: .shortened))")
            Text("Duration - \(dateComponentsFormatter.string(from: workout.duration)!)")
            Text("Distance - \(distanceFormatter.string(fromValue: workout.totalDistance(unitPrefix: .kilo), unit: .kilometer))")
        }
    }
}
