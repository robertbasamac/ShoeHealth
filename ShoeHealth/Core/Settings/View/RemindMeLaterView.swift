//
//  RemindMeLaterView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.09.2024.
//

import SwiftUI

struct RemindMeLaterView: View {
    
    @Environment(SettingsManager.self) private var settingsManager
    @Binding var selection: PresetTime
    
    @State private var customValue: Int = 1
    @State private var customUnit: TimeUnit = .minutes
    
    @FocusState private var isCustomInputFocused: Bool
    
    var body: some View {
        Form {
            selectedTimeInfoSection
            
            presetsSection
            
            customTimeSection
        }
        .listSectionSpacing(.compact)
        .navigationTitle("Remind me after")
        .toolbar {
            toolbarItems
        }
        .onAppear {
            initCustomProperties()
        }
    }
}

// MARK: - View Components

extension RemindMeLaterView {
    
    @ViewBuilder
    private var selectedTimeInfoSection: some View {
        Section {
            Text("You've set your time to ")
                .font(.body) +
            Text("\(selection.duration.value) \(selection.duration.unit.rawValue)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.accent) +
            Text(".")
                .font(.body)

        } footer: {
            Text("The time set here will be used to reschedule new workout notifications when you select \"Remind me later\" after long pressing on the workout notifications.")
                .font(.footnote)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 20))
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var presetsSection: some View {
        Section {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                spacing: 16
            ) {
                ForEach(PresetTime.allCases, id: \.self) { presetTime in
                    PresetTimeCell(
                        presetTime: presetTime,
                        selection: selection,
                        onTap: {
                            selection = presetTime
                            isCustomInputFocused = false
                        }
                    )
                }
                
                Text("Custom")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .padding(8)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.containerBackground)
                    .foregroundColor(
                        selection == PresetTime.custom(
                            value: customValue,
                            unit: customUnit
                        ) ? Color.theme.accent : .primary
                    )
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                selection == PresetTime.custom(
                                    value: customValue,
                                    unit: customUnit
                                ) ? Color.theme.accent : Color.clear,
                                lineWidth: 2
                            )
                            .padding(1)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .onTapGesture {
                        isCustomInputFocused = true
                        selection = PresetTime.custom(value: customValue, unit: customUnit)
                    }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        } header: {
            Text("Preset Times")
                .font(.footnote)
        }
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var customTimeSection: some View {
        Section {
            HStack(spacing: 16) {
                TextField("Value", value: $customValue, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .focused($isCustomInputFocused)
                    .frame(width: 80)
                
                Picker("Unit", selection: $customUnit) {
                    Text("\(TimeUnit.unit(for: customValue, unitType: TimeUnit.minute).rawValue.capitalized)")
                        .tag(TimeUnit.unit(for: customValue, unitType: TimeUnit.minute))
                    Text("\(TimeUnit.unit(for: customValue, unitType: TimeUnit.hour).rawValue.capitalized)")
                        .tag(TimeUnit.unit(for: customValue, unitType: TimeUnit.hour))
                    Text("\(TimeUnit.unit(for: customValue, unitType: TimeUnit.day).rawValue.capitalized)")
                        .tag(TimeUnit.unit(for: customValue, unitType: TimeUnit.day))
                }
                .pickerStyle(MenuPickerStyle())
            }
            .onChange(of: customValue) { _, newValue in
                if newValue == 0 {
                    customValue = 1
                } else {
                    handleCustomValueChange(newValue)
                }
            }
            .onChange(of: customUnit) { _, newValue in
                handleCustomUnitChange(newValue)
            }
        } header: {
            Text("Custom time input")
                .font(.footnote)

        } footer: {
            Text("Value must be greater than 0.")
                .font(.footnote)

        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button("Done") {
                isCustomInputFocused = false
            }
        }
    }
}

// MARK: - Helper Methods

extension RemindMeLaterView {
    
    private func handleCustomValueChange(_ newValue: Int) {
        customUnit = TimeUnit.unit(for: newValue, unitType: customUnit)
        
        if newValue == 5 && customUnit == .minutes {
            selection = .fiveMinutes
        } else if newValue == 10 && customUnit == .minutes {
            selection = .tenMinutes
        } else if newValue == 15 && customUnit == .minutes {
            selection = .fifteenMinutes
        } else if newValue == 30 && customUnit == .minutes {
            selection = .thirtyMinutes
        } else if newValue == 1 && customUnit == .hour {
            selection = .oneHour
        } else {
            selection = PresetTime.custom(value: newValue, unit: customUnit)
        }
    }
    
    private func handleCustomUnitChange(_ newValue: TimeUnit) {
        if customValue == 5 && newValue == .minutes {
            selection = .fiveMinutes
        } else if customValue == 10 && newValue == .minutes {
            selection = .tenMinutes
        } else if customValue == 15 && newValue == .minutes {
            selection = .fifteenMinutes
        } else if customValue == 30 && newValue == .minutes {
            selection = .thirtyMinutes
        } else if customValue == 1 && newValue == .hour {
            selection = .oneHour
        } else {
            selection = PresetTime.custom(value: customValue, unit: newValue)
        }
    }
    
    private func initCustomProperties() {
        let remindMeLaterTime = settingsManager.remindMeLaterTime
        
        switch remindMeLaterTime {
        case .fiveMinutes, .tenMinutes, .fifteenMinutes, .thirtyMinutes, .oneHour:
            customValue = remindMeLaterTime.duration.value
            customUnit = remindMeLaterTime.duration.unit
        case .custom(let value, let unit):
            customValue = value
            customUnit = unit
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selection: PresetTime = .fiveMinutes
    
    NavigationStack {
        RemindMeLaterView(selection: $selection)
    }
}
