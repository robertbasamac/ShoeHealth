//
//  SectionHeightPreferenceKey.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 16.02.2025.
//

import SwiftUI

struct SectionHeightPreferenceKey: PreferenceKey {
    
    static let defaultValue: [String: CGFloat] = [:]
    
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { current, _ in current })
    }
}
