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
        HStack {
            Image(systemName: "figure.run.circle.fill")
                .resizable()
                .foregroundStyle(Color.accentColor, LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.01), Color.accentColor.opacity(0.1)]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                Text("\(workout.endDate.formatted(date: .numeric, time: .shortened))")    
                    .font(.caption)
                
                Text("\(distanceFormatter.string(fromValue: Double(workout.totalDistance(unitPrefix: .kilo)), unit: .kilometer).uppercased())")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
