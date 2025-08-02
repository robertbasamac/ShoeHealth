//
//  HeaderScrollTargetBehavior.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.04.2024.
//

import SwiftUI

// MARK: - HeaderScrollTargetBehavior

struct HeaderScrollTargetBehavior: ScrollTargetBehavior {
    
    enum Mode {
        case image
        case noImage
    }

    let mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }

    static func header(for shoe: Shoe) -> HeaderScrollTargetBehavior {
        HeaderScrollTargetBehavior(mode: shoe.image == nil ? .noImage : .image)
    }

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        switch mode {
        case .image:
            if target.rect.minY < 250 {
                if target.rect.minY <= 30 {
                    target.rect.origin.y = .zero
                } else if target.rect.minY > 170 {
                    target.rect.origin.y = 250
                } else if target.rect.minY > 140 {
                    target.rect.origin.y = 140
                }
            }
        case .noImage:
            if target.rect.minY < 110 {
                if target.rect.minY < 30 {
                    target.rect.origin.y = .zero
                } else {
                    target.rect.origin.y = 110
                }
            }
        }
    }
}

// MARK: - HeaderScrollTargetBehavior

extension ScrollTargetBehavior where Self == HeaderScrollTargetBehavior {
    
    internal static func dynamicStretchyHeader(for shoe: Shoe) -> HeaderScrollTargetBehavior {
        HeaderScrollTargetBehavior(mode: shoe.image == nil ? .noImage : .image)
    }
}
