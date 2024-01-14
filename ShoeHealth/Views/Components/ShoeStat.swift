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
    private var alignement: HorizontalAlignment
    
    init(title: String, value: String, color: Color, alignement: HorizontalAlignment = .center) {
        self.title = title
        self.value = value
        self.color = color
        self.alignement = alignement
    }
    
    var body: some View {
        VStack(alignment: alignement, spacing: 0) {
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
