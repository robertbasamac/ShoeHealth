//
//  HeaderScrollTargetBehavior.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.04.2024.
//

import SwiftUI

struct StaticHeaderScrollTargetBehavior: ScrollTargetBehavior {
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < 75 {
            if target.rect.minY < 25 {
                target.rect.origin = .zero
            } else {
                target.rect.origin = .init(x: 0, y: 75)
            }
        }
    }
}

extension ScrollTargetBehavior where Self == StaticHeaderScrollTargetBehavior {

    internal static var staticHeader: StaticHeaderScrollTargetBehavior { .init() }
}
