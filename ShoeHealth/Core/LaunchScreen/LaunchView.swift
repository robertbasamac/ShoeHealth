//
//  LaunchView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 01.11.2024.
//

import SwiftUI

struct LaunchView: View {
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Image("ShoeHealth-transparent")
                .resizable()
                .frame(width: 150, height: 150)
        }
    }
}

// MARK: - Preview

#Preview {
    LaunchView()
}
