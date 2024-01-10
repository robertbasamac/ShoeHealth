//
//  ShoeStat.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.01.2024.
//

import SwiftUI

struct ShoeStat: View {
    
    private var title: String
    private var value: String
    private var color: Color
    
    init(title: String, value: String, color: Color) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
            Text(value)
                .font(.title3)
                .foregroundStyle(color)
        }
    }
}

#Preview {
    ShoeStat(title: "CURRENT", value: "3KM", color: Color.yellow)
}
