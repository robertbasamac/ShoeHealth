//
//  WelcomePage.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 12.11.2024.
//

import SwiftUI

struct WelcomePage: View {
    
    let features = [
        WelcomeItem(image: "shoe.2.fill", title: "Add Your Shoes", description: "Manually add your shoes and track their wear based on their activity."),
        WelcomeItem(image: "figure.run.circle.fill", title: "Import Running Workouts", description: "Assign each workout to a shoe pair to track their lifespan, wear and statistics."),
        WelcomeItem(image: "link", title: "Assign Workouts To Shoe", description: "Assign each workout to a shoe pair to track their lifespan, wear and statistics."),
        WelcomeItem(image: "bell.fill", title: "Notifications", description: "Receive notifications whenever a new workout is available or when shoes's wear condition changes.")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Shoe Health")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal, 40)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(features) { item in
                        WelcomeItemCard(item: item)
                    }
                }
                .padding(.horizontal, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 20)
        .padding(.bottom, 30)
    }
}

struct WelcomeItemCard: View {
    
    var item: WelcomeItem
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: item.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .foregroundStyle(Color.theme.accent)
            
            VStack(alignment: .leading) {
                Text(item.title)
                
                Text(item.description)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    OnboardingScreen()
}
