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
    
    @State private var selectedTab: OnboardingTab = .welcome

    @AppStorage("IS_ONBOARDING") var isOnboarding: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                WelcomePage()
                    .tag(OnboardingTab.welcome)
                
                OnboardingPage(image: OnboardingTab.healthKitAccess.image,
                               title: Prompts.HealthAccess.title,
                               description: Prompts.HealthAccess.description,
                               note: Prompts.HealthAccess.note
                )
                .tag(OnboardingTab.healthKitAccess)
                
                OnboardingPage(image: OnboardingTab.notificationAccess.image,
                               title: Prompts.Notifications.title,
                               description: Prompts.Notifications.description,
                               note: Prompts.Notifications.note
                )
                .tag(OnboardingTab.notificationAccess)
            }
            .tabViewStyle(.page)
            .onAppear {
                UIScrollView.appearance().isScrollEnabled = false
            }
            
            continueButton
                .animation(.none, value: selectedTab)
        }
        .background(.black)
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
    private var continueButton: some View {
        Button {
            withAnimation {
                switch selectedTab {
                case .welcome:
                    selectedTab = .healthKitAccess
                case .healthKitAccess:
                    if onboardingViewModel.isHealthAuthorized {
                        selectedTab = .notificationAccess
                    } else {
                        requestHealthKitAccess()
                    }
                case .notificationAccess:
                    if onboardingViewModel.isNotificationsAuthorized{
                        isOnboarding = false
                    } else {
                        requestNotificationAccess()
                    }
                }
            }
        } label: {
            Group {
                switch selectedTab {
                case .welcome, .healthKitAccess:
                    Text("Continue")
                case .notificationAccess:
                    if onboardingViewModel.isNotificationsAuthorized {
                        Text("Get Started")
                    } else {
                        Text("Continue")
                    }
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .font(.title2)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 15))
        .tint(.white)
        .padding(.bottom, 40)
        .padding(.horizontal, 40)
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

// MARK: - Previews

#Preview {
    OnboardingScreen()
}
