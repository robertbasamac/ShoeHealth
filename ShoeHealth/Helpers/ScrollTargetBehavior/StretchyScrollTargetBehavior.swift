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
            if target.rect.minY <= 30 {
                target.rect.origin.y = .zero
            } else if target.rect.minY > 170 {
                target.rect.origin.y = 250
            } else if target.rect.minY > 140 {
                target.rect.origin.y = 140
            }
        }
    }
}

extension ScrollTargetBehavior where Self == StretchyHeaderScrollTargetBehavior {

    internal static var stretchyHeader: StretchyHeaderScrollTargetBehavior { .init() }
}
