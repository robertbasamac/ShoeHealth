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
    
    private var container: ModelContainer
    
    @StateObject var navigationRouter: NavigationRouter = .init()
    @State var shoesViewModel: ShoesViewModel
    
    init() {
        self.container = {
            let container: ModelContainer
            
            do {
                container = try ModelContainer(for: Shoe.self)
            } catch {
                fatalError("Failed to create ModelContainer for Shoe.")
            }
            
            return container
        }()
        
        self._shoesViewModel = State(wrappedValue: ShoesViewModel(modelContext: container.mainContext))
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
        .modelContainer(container)
    }
}
