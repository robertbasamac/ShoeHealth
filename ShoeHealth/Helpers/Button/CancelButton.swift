//
//  CamcelnButton.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.08.2025.
//

import SwiftUI

struct CancelButton<Label>: View where Label: View {
    
    let label: Label
    let action: @MainActor () -> Void
    
    init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.action = action
    }
    
    var body: some View {
        if #available(iOS 26, *) {
            Button(role: .cancel) {
                action()
            } label: {
                Image(systemName: "xmark")
            }
        } else {
            Button {
                action()
            } label: {
                label
            }
        }
    }
}
