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
        
    @StateObject var navigationRouter: NavigationRouter = .init()
    @State var shoesViewModel: ShoesViewModel
    
    init() {
        self._shoesViewModel = State(wrappedValue: ShoesViewModel(modelContext: ShoesStore.container.mainContext))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationRouter)
                .environment(shoesViewModel)
                .preferredColorScheme(.dark)
                .onAppear {
                    appDelegate.app = self
                }
        }
        .modelContainer(ShoesStore.container)
    }
}
