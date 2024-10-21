//
//  BlurredCapsuleButtonStyle.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.05.2024.
//

import SwiftUI

struct BlurredCapsuleButtonStyle: ButtonStyle {
    
    var opacity: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        MyButton(configuration: configuration, opacity: opacity)
    }
    
    struct MyButton: View {
        let configuration: ButtonStyle.Configuration
        var opacity: CGFloat
        
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        var body: some View {
            configuration.label
                .foregroundStyle(isEnabled ? Color.theme.accent: Color.gray)
                .frame(height: 34)
                .padding(.horizontal, 12)
                .background(.bar.opacity(opacity), in: .capsule(style: .circular))
        }
    }
}

extension ButtonStyle where Self == BlurredCapsuleButtonStyle {
    
    static func blurredCapsule(_ opacity: CGFloat) -> Self {
        BlurredCapsuleButtonStyle(opacity: opacity)
    }
}
