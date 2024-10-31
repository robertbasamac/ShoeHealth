//
//  SettingsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.04.2024.
//

import SwiftUI

struct SettingsTab: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var store: StoreManager
    @Environment(SettingsManager.self) private var settingsManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @State private var remindMeLaterTime: PresetTime = SettingsManager.shared.remindMeLaterTime
    
    var body: some View {
        Form {
            Section {
                Picker("Unit of Measure", selection: $unitOfMeasure) {
                    ForEach(UnitOfMeasure.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
            } footer: {
                Text(Prompts.Settings.unitOfMeasure)
            }
            
            Section {
                NavigationLink {
                    RemindMeLaterView(selection: $remindMeLaterTime)
                } label: {
                    VStack(alignment: .leading) {
                        Text("Remind me after")
                            .badge("\(remindMeLaterTime.duration.value) \(remindMeLaterTime.duration.unit.rawValue)")
                    }
                }
            } footer: {
                Text(Prompts.Settings.remindMeLater)
            }
            
            Section {
                Button {
                    navigationRouter.showPaywall.toggle()
                } label: {
                    HStack {
                        Text("Unlock Full Access")
                        Spacer()
                        Text("\(store.getBadge())")
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                            .imageScale(.small)
                            .foregroundStyle(.secondary.opacity(0.5))
                            .imageScale(.small)
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .onChange(of: settingsManager.unitOfMeasure) { _, newValue in
            unitOfMeasure = newValue
        }
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
            .environmentObject(StoreManager())
    }
}
