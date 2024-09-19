//
//  SettingsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.04.2024.
//

import SwiftUI

struct SettingsTab: View {
    
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @State private var remindMeLaterTime: PresetTime = SettingsManager.shared.remindMeLater

    var body: some View {
        Form {
            Section {
                Picker("Unit of Measure", selection: $unitOfMeasure) {
                    Text(UnitOfMeasure.metric.rawValue).tag(UnitOfMeasure.metric)
                    Text(UnitOfMeasure.imperial.rawValue).tag(UnitOfMeasure.imperial)
                }
            } footer: {
                Text("Used to set the unit for all measurements displayed in the app.")
            }
            
            Section {
                NavigationLink {
                    ReminderTimeSelectionView(selection: $remindMeLaterTime)
                } label: {
                    VStack(alignment: .leading) {
                        Text("Remind me after")
                            .badge("\(remindMeLaterTime.duration.value) \(remindMeLaterTime.duration.unit.rawValue)")
                    }
                }
            } footer: {
                Text("The time set here will be used to reschedule new workout notifications when you select \"Remind me later\" after long pressing on the workout notifications.")
            }
        }
        .listSectionSpacing(.compact)
        .onChange(of: unitOfMeasure) { _, newValue in
            settingsManager.setUnitOfMeasure(to: newValue)
        }
        .onChange(of: remindMeLaterTime) { _, newValue in
            settingsManager.setRemindMeLaterTime(to: newValue)
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
            .environment(SettingsManager.shared)
    }
}