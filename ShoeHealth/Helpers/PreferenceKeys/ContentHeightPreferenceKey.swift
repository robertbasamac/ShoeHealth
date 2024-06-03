//
//  ContentHeightPreferenceKey.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 11.01.2024.
//

import Foundation
import SwiftUI

struct ContentHeightPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
