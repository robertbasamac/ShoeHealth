//
//  View.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 06.05.2024.
//

import SwiftUI

extension View {
    
    func asHeader() -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .contentShape(.rect)
            .dynamicTypeSize(DynamicTypeSize.small...DynamicTypeSize.xxLarge)
    }
    
    func roundedContainer() -> some View {
        self
            .background(Color.theme.containerBackground, in: .rect(cornerRadius: 10))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
    }
    
    func asHeaderTextButton() -> some View {
        self
            .font(.system(size: 17))
            .padding(.horizontal, 12)
            .frame(height: 30)
    }
    
    func asHeaderImageButton() -> some View {
        self
            .font(.system(size: 17, weight: .semibold))
            .frame(width: 30, height: 30)
    }
}
