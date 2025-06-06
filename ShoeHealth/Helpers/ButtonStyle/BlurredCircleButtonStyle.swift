//
//  BlurredCircleButtonStyle.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.05.2024.
//

import SwiftUI

struct BlurredCircleButtonStyle: ButtonStyle {
    
    var opacity: CGFloat
    
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? Color.accentColor : Color.gray)
            .frame(width: 34, height: 34)
            .background(.bar.opacity(opacity), in: .circle)
    }
}

extension ButtonStyle where Self == BlurredCircleButtonStyle {
    static func blurredCircle(_ opacity: CGFloat) -> Self {
        BlurredCircleButtonStyle(opacity: opacity)
    }
}
