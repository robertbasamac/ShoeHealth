//
//  LastRunView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 06.09.2024.
//

import SwiftUI
import HealthKit

struct LastRunView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(HealthManager.self) var healthManager
    @Environment(SettingsManager.self) private var settingsManager
     
    @Binding private var selectedShoe: Shoe?
    
    init(selectedShoe: Binding<Shoe?>) {
           print("LastRunView init")
           self._selectedShoe = selectedShoe
       }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Last Run")
                .asHeader()
            
            Group {
                if let lastRun = healthManager.lastWorkout {
                    VStack(spacing: 8) {
                        HStack {
                            runDateAndTimeSection(lastRun.workout)
                            runUsedShoeSection(lastRun.workout)
                        }
                        .padding(.horizontal, 20)
                        
                        Rectangle()
                            .fill(.background)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                        
                        runStatsSection(lastRun)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 10)
                }
                else {
                    Text("Your latest run will appear here.")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .roundedContainer()
        }
    }
}

extension LastRunView {
    
    @ViewBuilder
    private func runDateAndTimeSection(_ run: HKWorkout) -> some View {
        VStack(alignment: .center) {
            Text(run.startDateAsString)
            Text("\(run.startTimeAsString) - \(run.endTimeAsString)")
                .foregroundStyle(.secondary)
                .textScale(.secondary)
        }
        .font(.system(size: 17, weight: .regular))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func runStatsSection(_ run: RunningWorkout) -> some View {
        VStack(spacing: 8) {
            HStack {
                StatCell(label: "Duration", value: run.workout.durationAsString, color: .yellow, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Distance", value: String(format: "%.2f", run.workout.totalDistance(unit: settingsManager.unitOfMeasure.unit)), unit: settingsManager.unitOfMeasure.symbol, color: .blue, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Avg Power", value: String(format: "%0.0f", run.wrappedAveragePower), unit: UnitPower.watts.symbol, color: Color.theme.greenEnergy, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Cadence", value: String(format: "%.0f", run.wrappedAAverageCadence), unit: "SPM", color: .cyan, textAlignment: .leading, containerAlignment: .leading)
            }
            
            Divider()
            
            HStack {
                StatCell(label: "Avg Pace", value: String(format: "%d'%02d\"", run.workout.averagePace(unit: settingsManager.unitOfMeasure.unit).minutes, run.workout.averagePace(unit: settingsManager.unitOfMeasure.unit).seconds), unit: "/\(settingsManager.unitOfMeasure.symbol)", color: .teal, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "Avg Heart Rate", value: String(format: "%.0f", run.wrappedAverageHeartRate), unit: "BPM", color: .red, textAlignment: .leading, containerAlignment: .leading)
            }
        }
    }
    
    @ViewBuilder
    private func runUsedShoeSection(_ run: HKWorkout) -> some View {
        Group {
            if let shoe = shoesViewModel.getShoe(ofWorkoutID: run.id) {
                VStack(alignment: .leading) {
                    Text("\(shoe.brand)")
                        .font(.callout)
//                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    
                    Text("\(shoe.model)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2, reservesSpace: false)
//                        .font(.system(size: 18))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .font(.title2.bold())
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
                .onTapGesture {
                    selectedShoe = shoe
                }
            } else {
                Text("No shoe selected for this workout.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.center)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        navigationRouter.showSheet = .addWorkoutToShoe(workoutID: run.id)
                    }
            }
        }
        .overlay(alignment: .leading) {
            Image(systemName: "shoe.2.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .offset(x: -50)
        }
    }
}

//#Preview {
//    LastRunView(lastRun: HKW, unitOfMeasure: UnitOfMeasure.metric, selectedShoe: .constant(Shoe.previewShoe))
//}
