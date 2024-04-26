//
//  StaticHeaderCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 22.04.2024.
//

import SwiftUI

struct StaticHeaderCell: View {
    
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(subtitle)
                .font(.headline)
            Text(title)
                .font(.largeTitle)
                .lineLimit(1)
                .minimumScale Factor(0.4)
                .fontWeight(.bold)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .padding(.top, 66)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    StaticHeaderCell(title: "Pegasus Turbo Next Nature", subtitle: "Nike")
}
