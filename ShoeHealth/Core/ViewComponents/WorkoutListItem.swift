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
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    var body: some View {
        HStack {
            Image(systemName: "figure.run.circle.fill")
                .resizable()
                .foregroundStyle(Color.theme.greenEnergy, LinearGradient(gradient: Gradient(colors: [Color.theme.greenEnergy.opacity(0.01), Color.theme.greenEnergy.opacity(0.1)]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                Text("\(workout.endDate.formatted(date: .numeric, time: .shortened))")    
                    .font(.caption)
                
                Group {
                    Text(String(format: "%.2f", workout.totalDistance(unit: unitOfMeasure.unit))) +
                    Text("\(unitOfMeasure.symbol)")
                        .textScale(.secondary)
                }
                .font(.title3)
                .foregroundStyle(Color.theme.greenEnergy)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: SettingsManager.shared.unitOfMeasure) { _, newValue in
            unitOfMeasure = newValue
        }
    }
}
