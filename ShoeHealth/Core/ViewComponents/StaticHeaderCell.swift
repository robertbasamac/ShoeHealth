//
//  StaticHeaderCell.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 22.04.2024.
//

import SwiftUI

struct StaticHeaderCell: View {
    
    var model: String
    var brand: String
    var nickname: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(nickname)
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundStyle(Color.theme.accent)
                .italic()
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(brand)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                Text(model)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .lineLimit(2)
//                    .minimumScaleFactor(0.4)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        StaticHeaderCell(model: "Pegasus Turbo Next Nature", brand: "Nike", nickname: "Shoey")
        Spacer()
    }
}
