//
//  RunTypeCapsule.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 24.09.2025.
//

import SwiftUI

struct RunTypeCapsule: View {
    
    let runType: RunType
    let foregroundColor: Color
    let backgroundColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Text(runType.rawValue.capitalized)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(foregroundColor)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(backgroundColor, in: .capsule(style: .circular))
            .dynamicTypeSize(...DynamicTypeSize.large)
            .onTapGesture {
                withAnimation { onTap() }
            }
    }
    
    static let capsuleSpace: CGFloat = 6
}
