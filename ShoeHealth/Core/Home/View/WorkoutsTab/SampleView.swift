//
//  SampleView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 20.05.2024.
//

import SwiftUI
import HealthKit

struct SampleView: View {
    
    @Environment(HealthManager.self) private var healthManager
    var workout: HKWorkout
    
    @State private var samples: [HKQuantitySample] = []
    
    var body: some View {
        List {
            Text("\(samples.count) samples")
            ForEach(samples, id: \.self) { sample in
                HStack(spacing: 20) {
                    Text(String(format: "%.2f m", sample.quantity.doubleValue(for: HKUnit.meter()).rounded(toPlaces: 2)))
                    
                    Spacer()
                    
                    VStack {
                        Text(dateTimeFormatter.string(from: sample.startDate))
                        Text(dateTimeFormatter.string(from: sample.endDate))
                    }
                }
            }
        }
        .task {
            healthManager.fetchDistanceSamples(for: workout) { samples in
                self.samples = samples
            }
        }
        .navigationTitle("Workout samples")
    }
}

//#Preview {
//    SampleView()
//}
