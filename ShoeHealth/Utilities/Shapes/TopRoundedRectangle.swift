//
//  TopRoundedRectangle.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.12.2023.
//

import Foundation
import SwiftUI

struct TopRoundedRectangle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.midX, y: rect.minY),
                    radius: cornerRadius)

        // Top right corner
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
                    radius: cornerRadius)

        // Bottom right and bottom left corners (straight lines)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}
