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
    var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(nickname)
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundStyle(Color.theme.accent)
                .italic()
                .lineLimit(1)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(brand)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .lineLimit(1)
                
                Text(model)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .lineLimit(1)
                
                Text("Purchased on \(dateFormatter.string(from: date))")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        StaticHeaderCell(model: "Pegasus Turbo Next Nature", brand: "Nike", nickname: "Shoey", date: .now)
            .frame(height: 110)
        Spacer()
    }
}
