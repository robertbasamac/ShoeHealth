//
//  BlurredCircleButtonStyle.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.05.2024.
//

import SwiftUI

struct BlurredCircleButtonStyle: ButtonStyle {
    
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
                .foregroundColor(isEnabled ? Color.theme.accent : Color.gray)
                .frame(width: 34, height: 34)
                .background(.bar.opacity(opacity), in: .circle)
        }
    }
}

extension ButtonStyle where Self == BlurredCircleButtonStyle {
    static func blurredCircle(_ opacity: CGFloat) -> Self {
        BlurredCircleButtonStyle(opacity: opacity)
    }
}
