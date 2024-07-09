//
//  OnboardingView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.06.2024.
//

import SwiftUI
import HealthKit

struct OnboardingScreen: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var onboardingViewModel = OnboardingViewModel()
    
    @State private var selectedTab: OnboardingTab = .healthKitAccess

    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                OnboardingPage(image: "AppleHealth",
                               title: Prompts.HealthAccess.title,
                               description: Prompts.HealthAccess.description,
                               note: Prompts.HealthAccess.note,
                               buttonTitle: "Sync Health Data",
                               disableButton: onboardingViewModel.isHealthAuthorized,
                               buttonAction: requestHealthKitAccess
                )
                .tag(OnboardingTab.healthKitAccess)
                
                OnboardingPage(image: "bell.badge.fill",
                               title: Prompts.Notifications.title,
                               description: Prompts.Notifications.description,
                               note: Prompts.Notifications.note,
                               statusInfo: notificationsStatusInfo(),
                               buttonTitle: notificationsButtonTitle(),
                               disableButton: disableNotificationButton(),
                               buttonAction: requestNotificationAccess
                )
                .tag(OnboardingTab.notificationAccess)
            }
            .tabViewStyle(.page)
            .onAppear {
                UIScrollView.appearance().isScrollEnabled = false
            }
            
            nextButton
                .animation(.none, value: selectedTab)
                .disabled(!onboardingViewModel.isHealthAuthorized)
        }
        .task {
            await onboardingViewModel.checkNotificationAuthorizationStatus()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {                
                Task {
                    await onboardingViewModel.checkNotificationAuthorizationStatus()
                }
            }
        }
    }
}

// MARK: - View Components

extension OnboardingScreen {

    @ViewBuilder
    private var nextButton: some View {
        Button {
            withAnimation {
                switch selectedTab {
                case .healthKitAccess:
                    selectedTab = .notificationAccess
                case .notificationAccess:
                    isOnboarding = false
                }
            }
        } label: {
            Group {
                switch selectedTab {
                case .healthKitAccess:
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .fontWeight(.light)
                case .notificationAccess:
                    Text("Get Started")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
            .frame(height: 44)
        }
        .tint(.white)
        .padding(.vertical, 10)
        .padding(.bottom, 40)
    }
}

// MARK: - Authorization requests

extension OnboardingScreen {
    
    private func requestHealthKitAccess() {
        Task {
            await onboardingViewModel.requestHealthAuthorization()
        }
    }
    
    private func requestNotificationAccess() {
        Task {
            await onboardingViewModel.requestNotificationAuthorization()
        }
    }
}

// MARK: - Notifications Helper Methods

extension OnboardingScreen {
    
    private func notificationsButtonTitle() -> String {
        switch onboardingViewModel.notificationAuthorizationStatus {
        case .denied:
            return "Open Settings"
        case .notDetermined, .authorized, .provisional, .ephemeral:
            return "Enable Notifications"
        @unknown default:
            return "Enable Notifications"
        }
    }
    
    private func notificationsStatusInfo() -> String {
        switch onboardingViewModel.notificationAuthorizationStatus {
        case .notDetermined:
            return ""
        case .denied:
            return """
                Permission denied.
                Press the button below to manually open your device settings and turn on notifications.
            """
        case .authorized, .provisional, .ephemeral:
            return ""
        @unknown default:
            return ""
        }
    }
    
    private func disableHealthButton() -> Bool {
        return onboardingViewModel.isHealthAuthorized
    }
    
    private func disableNotificationButton() -> Bool {
        switch onboardingViewModel.notificationAuthorizationStatus {
        case .notDetermined, .denied:
            return false
        case .authorized, .provisional, .ephemeral:
            return true
        @unknown default:
            return false
        }
    }
}

// MARK: - Previews

#Preview {
    OnboardingScreen()
}
