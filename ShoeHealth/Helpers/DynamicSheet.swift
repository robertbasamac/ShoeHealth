//
//  DynamicSheet.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 02.10.2025.
//

import SwiftUI

struct DynamicSheet<Content>: View where Content: View {
    
    var animation: Animation
    @ViewBuilder var content: Content
    
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        ZStack {
            content
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGSize.self) {
                    $0.size
                } action: { newValue in
                    if sheetHeight == .zero {
                        sheetHeight = min(newValue.height, windowSize.height - 110)
                    } else {
                        withAnimation(animation) {
                            sheetHeight = min(newValue.height, windowSize.height - 110)
                        }
                    }
                }
        }
        .modifier(SheetHeighModifier(height: sheetHeight))
    }
    
    var windowSize: CGSize {
        if let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return size
        }
        
        return .zero
    }
}

fileprivate struct SheetHeighModifier: ViewModifier, Animatable {
    
    var height: CGFloat
    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .presentationDetents(height == .zero ? [.medium] : [.height(height)])
            .interactiveDismissDisabled()
            .presentationCornerRadiusPreiOS26(Constants.presentationCornerRadius)
    }
}
