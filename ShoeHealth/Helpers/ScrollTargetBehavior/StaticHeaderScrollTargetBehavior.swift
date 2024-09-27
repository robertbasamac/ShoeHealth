//
//  HeaderScrollTargetBehavior.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.04.2024.
//

import SwiftUI

struct StaticHeaderScrollTargetBehavior: ScrollTargetBehavior {
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < 110 {
            if target.rect.minY < 30 {
                target.rect.origin.y = .zero
            } else {
                target.rect.origin.y = 110
            }
        }
    }
}

extension ScrollTargetBehavior where Self == StaticHeaderScrollTargetBehavior {

    internal static var staticHeader: StaticHeaderScrollTargetBehavior { .init() }
}
