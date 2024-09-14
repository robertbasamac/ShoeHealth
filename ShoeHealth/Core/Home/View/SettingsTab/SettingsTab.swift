//
//  SettingsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.04.2024.
//

import SwiftUI

struct SettingsTab: View {
    
    @Environment(SettingsManager.self) private var settingsManager
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    
    var body: some View {
        Form {
            HStack {
                Text("Unit of Measure")
                Spacer(minLength: 40)
                Picker("Unit", selection: $unitOfMeasure) {
                    Text(UnitOfMeasure.metric.rawValue).tag(UnitOfMeasure.metric)
                    Text(UnitOfMeasure.imperial.rawValue).tag(UnitOfMeasure.imperial)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button {
                Task {
                    await HealthManager.shared.requestHealthAuthorization()
                }
            } label: {
                Text("Request HK authorization")
            }
        }
        .onChange(of: unitOfMeasure) { _, newValue in
            settingsManager.setUnitOfMeasure(to: newValue)
        }
    }
}

// MARK: - Helper Methods

extension SettingsTab {
    
    func totalMinutes(from date: Date) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        return (hours * 60) + minutes
    }
    
    func dateFrom(totalMinutes: TimeInterval) -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes.truncatingRemainder(dividingBy: 60)
        
        var dateComponents = DateComponents()
        dateComponents.hour = Int(hours)
        dateComponents.minute = Int(minutes)
        
        return calendar.date(from: dateComponents)
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SettingsTab()
            .navigationTitle("Settings")
    }
}
