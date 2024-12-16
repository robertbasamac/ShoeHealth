//
//  Color.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.08.2024.
//

import Foundation
import SwiftUI

extension Color {
    
    static let theme = ColorTheme()
}

struct ColorTheme {
    
    let accent = Color("AccentColor")
    let greenEnergy = Color("GreenEnergy")
    let background = Color(uiColor: .systemBackground)
    let containerBackground = Color(uiColor: .secondarySystemBackground)
}

