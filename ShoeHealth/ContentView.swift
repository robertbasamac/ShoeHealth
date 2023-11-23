//
//  ContentView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var healthKitManager = HealthKitManager.shared
    
    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .default
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }
    
    private var distanceFormatter: LengthFormatter {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.minimumFractionDigits = 2
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(healthKitManager.workouts, id: \.self) { workout in
                    VStack(alignment: .leading) {
                        Text("\(workout.startDate.formatted(date: .long, time: .shortened))")
                        Text("Duration - \(formatter.string(from: workout.duration)!)")
                        Text("Distance - \(distanceFormatter.string(fromValue: workout.totalDistance(unitPrefix: .kilo), unit: .kilometer))")
                    }
                }
            }
            .navigationTitle("Running Workouts")
            .task {
                await healthKitManager.readRunningWorkouts()
            }
            .refreshable {
                await healthKitManager.readRunningWorkouts()
            }
        }
    }
}

#Preview {
    ContentView()
}
