//
//  StretchyScrollTargetBehavior.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.04.2024.
//

import SwiftUI

struct StretchyHeaderScrollTargetBehavior: ScrollTargetBehavior {
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < 250 {
            if target.rect.minY <= 50 {
                target.rect.origin = .zero
            } else if target.rect.minY > 175 {
                target.rect.origin = .init(x: 0, y: 250)
            }
        }
    }
}

extension ScrollTargetBehavior where Self == StretchyHeaderScrollTargetBehavior {

    internal static var stretchyHeader: StretchyHeaderScrollTargetBehavior { .init() }
}
