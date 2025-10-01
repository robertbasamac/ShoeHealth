//
//  CapsuleStyleHelper.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 24.09.2025.
//

import SwiftUI

struct CapsuleColorStyle {
    
    let foreground: Color
    let background: Color
}

enum CapsuleStyleHelper {
    
    static func colorStyle(isDefault: Bool, isSuitable: Bool, isDisabled: Bool) -> CapsuleColorStyle {
        let foreground: Color
        let background: Color

        if isDefault {
            foreground = isDisabled ? Color.theme.accent.opacity(0.5) : Color.theme.accent
            background = Color.theme.accent.opacity(0.3)
        } else if isSuitable {
            foreground = isDisabled ? .primary.opacity(0.5) : .primary
            background = Color.primary.opacity(0.3)
        } else if isDisabled {
            foreground = .secondary
            background = Color.theme.containerBackground
        } else {
            foreground = .primary
            background = Color.theme.containerBackground
        }

        return CapsuleColorStyle(foreground: foreground, background: background)
    }
}
