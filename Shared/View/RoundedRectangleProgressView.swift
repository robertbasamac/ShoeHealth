//
//  RoundedRectangleProgressView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 15.04.2024.
//

import SwiftUI

struct RoundedRectangleProgressView: View {
    
    var progress: Double
    var color: Color
    
    var body: some View {
        if progress <= 0.875 {
            RoundedRectangle(cornerRadius: 10)
                .trim(from: 0.125, to: progress + 0.125)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-180))
                .padding(2)
                .animation(.snappy, value: progress)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .trim(from: 0.125, to: 1)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-180))
                    .padding(2)
                    .animation(.snappy, value: progress)
                RoundedRectangle(cornerRadius: 10)
                    .trim(from: 0, to: progress - 0.875)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-180))
                    .padding(2)
                    .animation(.snappy, value: progress)
            }
        }
    }
}

#Preview {
    RoundedRectangleProgressView(progress: 0.5, color: .orange)
        .frame(width: 200, height: 200)
}
