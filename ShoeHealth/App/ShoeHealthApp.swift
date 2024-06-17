//
//  ShoeHealthApp.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI
import SwiftData

@main
struct ShoeHealthApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject var navigationRouter = NavigationRouter()
    
    @State var shoesViewModel = ShoesViewModel(modelContext: ShoesStore.container.mainContext)
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationRouter)
                .environment(shoesViewModel)
                .preferredColorScheme(.dark)
                .onAppear {
                    appDelegate.shoesViewModel = shoesViewModel
                    appDelegate.navigationRouter = navigationRouter
                }
        }
        .modelContainer(ShoesStore.container)
    }
}
