//
//  MenuCapsuleButtonStyle.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 11.02.2025.
//

import SwiftUI

struct MenuCapsuleButtonStyle: ButtonStyle {
    
    var isSelected: Bool
    
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .fontWeight(.medium)
            .foregroundStyle(!isEnabled ? Color.gray : (isSelected ? Color.black : Color.primary))
            .padding(.vertical, 6)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.theme.accent : Color.theme.containerBackground, in: .capsule(style: .circular))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == MenuCapsuleButtonStyle {
    static func menuButton(_ isSeleced: Bool) -> Self {
        MenuCapsuleButtonStyle(isSelected: isSeleced)
    }
}
