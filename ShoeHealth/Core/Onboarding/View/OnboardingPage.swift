//
//  OnboardingPage.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 12.06.2024.
//

import SwiftUI

struct OnboardingPage: View {
    
    private let image: String
    private let title: String
    private let description: String
    private let note: String
    private let additionalInformation: String
    private let buttonTitle: String
    private let disableButton: Bool
    private let buttonAction: () -> Void

    init(image: String, title: String, description: String, note: String = "", statusInfo: String = "", buttonTitle: String, disableButton: Bool = false, buttonAction: @escaping () -> Void) {
        self.image = image
        self.title = title
        self.description = description
        self.note = note
        self.additionalInformation = statusInfo
        self.buttonTitle = buttonTitle
        self.disableButton = disableButton
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let _ = UIImage(named: image) {
                Image(image) // Asset catalog image
                    .resizable()
                    .frame(width: 84, height: 84)
            } else {
                Image(systemName: image) // SF Symbol
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.red, .white)
                    .frame(width: 84, height: 84)
            }
            
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2, reservesSpace: true)
            
            Text(description)
                .font(.body)
            
            if !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.pink)
            }
            
            Spacer()
            
            if !additionalInformation.isEmpty {
                Text(additionalInformation)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity)
            }
            
            Button(action: buttonAction) {
                Text(buttonTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .foregroundStyle(.black)
            .tint(.white)
            .disabled(disableButton)
        }
        .fontDesign(.rounded)
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview

#Preview {
    TabView {
        OnboardingPage(image: "AppleHealth",
                       title: Prompts.HealthAccess.title,
                       description: Prompts.HealthAccess.description,
                       note: Prompts.HealthAccess.note,
                       buttonTitle: "Sync Health Data") {}
        
        OnboardingPage(image: "bell.badge.fill",
                       title: Prompts.Notifications.title,
                       description: Prompts.Notifications.description,
                       note: Prompts.Notifications.note,
                       buttonTitle: "Enable Notifications") {}
    }
    .tabViewStyle(.page)
}
