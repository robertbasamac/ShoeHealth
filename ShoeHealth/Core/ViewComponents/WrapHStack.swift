//
//  WrapHStack.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.05.2025.
//

import SwiftUI

struct WrapHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    
    let data: Data
    let content: (Data.Element) -> Content

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(data, id: \.self) { item in
                content(item)
                    .padding(4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        width -= d.width
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        return result
                    })
            }
        }
    }
}
