//
//  ShoeHealthApp.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.11.2023.
//

import SwiftUI

@main
struct ShoeHealthApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Shoe.self], isAutosaveEnabled: true)
                .preferredColorScheme(.dark)
        }
    }
}
