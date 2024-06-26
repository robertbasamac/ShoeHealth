//
//  CircularProgressView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.01.2024.
//

import SwiftUI

struct CircularProgressView: View {
    
    private var progress: Double
    private var lineWidth: CGFloat
    private var color: Color
    
    init(progress: Double, lineWidth: CGFloat, color: Color) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.25),lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.smooth, value: progress)
        }
        .shadow(color: color.opacity(0.25), radius: lineWidth / 3)
        .padding(lineWidth / 2)
    }
}

// MARK: - Preview

#Preview {
    CircularProgressView(progress: 0.3, lineWidth: 20, color: Color.green)
}
