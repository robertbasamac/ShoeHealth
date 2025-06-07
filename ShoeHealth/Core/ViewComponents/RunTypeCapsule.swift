//
//  RunTypeCapsule.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 05.06.2025.
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
            .fontWeight(.medium)
            .foregroundStyle(foregroundColor)
            .padding(6)
            .frame(maxWidth: .infinity)
            .background(backgroundColor, in: .capsule(style: .circular))
            .dynamicTypeSize(...DynamicTypeSize.large)
            .onTapGesture {
                withAnimation { onTap() }
            }
    }
}
