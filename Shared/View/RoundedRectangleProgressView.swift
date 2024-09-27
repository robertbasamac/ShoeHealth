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
    var width: CGFloat
    var cornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.black, lineWidth: 12)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 8)

            if progress <= 0.875 {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .trim(from: 0.125, to: progress + 0.125)
                    .stroke(color, style: .init(lineWidth: 8, lineCap: .butt))
                    .rotationEffect(.degrees(-180))
                    .animation(.snappy, value: progress)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .trim(from: 0.125, to: 1)
                        .stroke(color, style: .init(lineWidth: 8, lineCap: .butt))
                        .rotationEffect(.degrees(-180))
                        .animation(.snappy, value: progress)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .trim(from: 0, to: progress - 0.875)
                        .stroke(color, style: .init(lineWidth: 8, lineCap: .butt))
                        .rotationEffect(.degrees(-180))
                        .animation(.smooth, value: progress)
                }
            }
        }
        .frame(width: width, height: width)
        .clipShape(.rect(cornerRadius: 10))
    }
}

// MARK: - Previews

#Preview {
    RoundedRectangleProgressView(progress: 0.5, color: .orange, width: 200, cornerRadius: 10)
}
