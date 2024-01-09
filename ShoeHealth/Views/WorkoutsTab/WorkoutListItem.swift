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
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.95), .black.opacity(0.75)]), startPoint: .leading, endPoint: .trailing))
                .background {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 29, height: 29)
                }
            
            VStack(alignment: .leading) {
                Text("\(workout.endDate.formatted(date: .numeric, time: .shortened))")    
                    .font(.caption)
                
                Text("\(distanceFormatter.string(fromValue: workout.totalDistance(unitPrefix: .kilo), unit: .kilometer).uppercased())")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
