//
//  SampleView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 20.05.2024.
//

import SwiftUI
import HealthKit

struct SampleView: View {
    
    var workout: HKWorkout
    
    @State private var samples: [HKQuantitySample] = []
    
    var body: some View {
        List {
            Text("\(samples.count) samples")
            ForEach(samples, id: \.self) { sample in
                HStack(spacing: 20) {
                    Text(String(format: "%.2f m", sample.quantity.doubleValue(for: HKUnit.meter()).rounded(toPlaces: 2)))

                    Spacer()
                    
                    Text(dateTimeFormatter.string(from: sample.endDate))
                }
            }
        }
        .task {
            HealthKitManager.shared.fetchDistanceSamples(for: workout) { samples in
                self.samples = samples.sorted(by: { $0.endDate > $1.endDate })
            }
        }
        .navigationTitle("Workout samples")
    }
}

//#Preview {
//    SampleView()
//}
