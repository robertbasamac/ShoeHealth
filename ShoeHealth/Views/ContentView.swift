//
//  ContentView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var healthKitManager = HealthKitManager.shared

    @State private var tabSelection: Tab = .shoes
        
    enum Tab: String, Identifiable {
        var id: Self { self }
        
        case shoes = "Shoes"
        case workouts = "Workouts"
        
        var systemImageName: String {
            switch self {
            case .shoes:
                return "shoe"
            case .workouts:
                return "figure.run.square.stack"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationStack {
                ShoesTab()
                    .navigationTitle("Shoes")
            }
            .tabItem {
                Label(Tab.shoes.rawValue, systemImage: Tab.shoes.systemImageName)
            }
            .tag(Tab.shoes)
            
            NavigationStack {
                WorkoutsTab()
                    .navigationTitle("Workouts")
            }
            .tabItem {
                Label(Tab.workouts.rawValue, systemImage: Tab.workouts.systemImageName)
            }
            .tag(Tab.workouts)
        }
        .task {
            await healthKitManager.fetchRunningWorkouts()
        }
    }
}

// MARK: - Previews
#Preview("Filled") {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}

#Preview("Empty") {
    ContentView()
        .modelContainer(PreviewSampleData.emptyContainer)
}
