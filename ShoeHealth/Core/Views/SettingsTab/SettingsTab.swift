//
//  SettingsTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.04.2024.
//

import SwiftUI

struct SettingsTab: View {
    
    var body: some View {
        ScrollView(.vertical) {
            Text("Settings")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsTab()
            .navigationTitle("Settings")
    }
}
