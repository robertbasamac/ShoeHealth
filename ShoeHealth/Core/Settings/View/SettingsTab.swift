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
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @State private var remindMeLaterTime: PresetTime = SettingsManager.shared.remindMeLaterTime
    
    var body: some View {
        Form {
            unitOfMeasureSection
            
            remindMeLaterSection
            
            faqSection
            
            notificationsSection
            
            unlockFullAccessSection
        }
        .listSectionSpacing(.compact)
        .navigationTitle("Settings")
        .onChange(of: settingsManager.unitOfMeasure) { _, newValue in
            unitOfMeasure = newValue
        }
        .onChange(of: unitOfMeasure) { _, newValue in
            settingsManager.setUnitOfMeasure(to: newValue)
        }
        .onChange(of: remindMeLaterTime) { _, newValue in
            settingsManager.setRemindMeLaterTime(to: newValue)
        }
        .task {
            await NotificationManager.shared.retrieveNotificationAuthorizationStatus()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                Task {
                    await NotificationManager.shared.retrieveNotificationAuthorizationStatus()
                }
            }
        }
    }
}

// MARK: - View Components

extension SettingsTab {
    
    @ViewBuilder
    private var unitOfMeasureSection: some View {
        Section {
            Picker("Unit of Measure", selection: $unitOfMeasure) {
                ForEach(UnitOfMeasure.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
        } footer: {
            Text(Prompts.Settings.unitOfMeasure)
                .font(.footnote)
        }
    }
    
    @ViewBuilder
    private var remindMeLaterSection: some View {
        
        Section {
            NavigationLink {
                RemindMeLaterView(selection: $remindMeLaterTime)
            } label: {
                VStack(alignment: .leading) {
                    Text("Remind me after")
                        .font(.body)
                        .badge("\(remindMeLaterTime.duration.value) \(remindMeLaterTime.duration.unit.rawValue)")
                }
            }
        } footer: {
            Text(Prompts.Settings.remindMeLater)
                .font(.footnote)
        }
    }
    
    @ViewBuilder
    private var faqSection: some View {
        Section {
            NavigationLink(destination: FAQView()) {
                Text("FAQ")
            }
        }
    }
    
    @ViewBuilder
    private var notificationsSection: some View {
        Section {
            Button {
                Task {
                    switch NotificationManager.shared.notificationAuthorizationStatus {
                    case .notDetermined:
                        let _ = await NotificationManager.shared.requestNotificationAuthorization()
                    case .denied, .authorized, .provisional, .ephemeral:
                        await NotificationManager.shared.openSettings()
                    @unknown default:
                        let _ = await NotificationManager.shared.requestNotificationAuthorization()
                    }
                }
            } label: {
                HStack {
                    Text("Notifications")
                        .font(.body)
                    Spacer()
                    Text("\(NotificationManager.shared.getBadge())")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .fontWeight(.semibold)
                        .imageScale(.small)
                        .foregroundStyle(.secondary.opacity(0.5))
                }
            }
            .foregroundStyle(.primary)
        }
    }
    
    @ViewBuilder
    private var unlockFullAccessSection: some View {
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
                }
                .font(.body)
            }
            .foregroundStyle(.primary)
        } footer: {
            HStack(spacing: 4) {
                Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                
                Text("and")
                
                Link("Privacy Policy", destination: URL(string: "https://github.com/robertbasamac/ShoeHealth/blob/master/APP_POLICY.md")!)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.footnote)
            .handleOpenURLInApp()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SettingsTab()
            .navigationTitle("Settings")
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager.shared)
            .environment(SettingsManager.shared)
    }
}
