//
//  ContentView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {    
    @State private var tabSelection: Tab = .workouts
        
    enum Tab: String, Identifiable {
        var id: Self { self }
        
        case workouts = "Workouts"
        case shoes = "Shoes"
        
        var systemImageName: String {
            switch self {
            case .workouts:
                return "figure.run.square.stack"
            case .shoes:
                return "shoe"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationStack {
                WorkoutsTab()
                    .navigationTitle("Running Workouts")
            }
            .tabItem {
                Label(Tab.workouts.rawValue, systemImage: Tab.workouts.systemImageName)
            }
            .tag(Tab.workouts)
            
            NavigationStack {
                ShoesTab()
                    .navigationTitle("Shoes")
            }
            .tabItem {
                Label(Tab.shoes.rawValue, systemImage: Tab.shoes.systemImageName)
            }
            .tag(Tab.shoes)
        }
    }
}

#Preview {
    ContentView()
}
