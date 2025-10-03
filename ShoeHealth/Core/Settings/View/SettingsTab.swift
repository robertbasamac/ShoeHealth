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
            subscriptionSection
            unitOfMeasureSection
            remindMeLaterSection
            notificationsSection
            appSection
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
    private var subscriptionSection: some View {
        Section {
            Button {
                navigationRouter.showPaywall.toggle()
            } label: {
                HStack {
                    Text("Active Plan")
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
        } header: {
            Text("Subscription")
        }
    }
    
    @ViewBuilder
    private var unitOfMeasureSection: some View {
        Section {
            Picker("Unit of Measure", selection: $unitOfMeasure) {
                ForEach(UnitOfMeasure.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
        } header: {
            Text("Options")
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
        } footer: {
            Text(Prompts.Settings.notificationsNote)
                .font(.footnote)
        }
    }
    
    @ViewBuilder
    private var appSection: some View {
        Section {
            Button {
                if let writeReviewURL = URL(string: "https://apps.apple.com/app/id6648781147?action=write-review") {
                    UIApplication.shared.open(writeReviewURL)
                }
            } label: {
                Text("Rate in App Store")
            }
            
            Button {
                UIApplication.shared.open(System.AppLinks.termsOfService)
            } label: {
                Text("Terms of Service")
            }
            
            Button {
                UIApplication.shared.open(System.AppLinks.privacyPolicy)
            } label: {
                Text("Privacy Policy")
            }
            
            NavigationLink(destination: FAQView()) {
                Text("FAQ")
            }
        } header: {
            Text("App")
        } footer: {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("App Version \(version)")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .tint(.primary)
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
