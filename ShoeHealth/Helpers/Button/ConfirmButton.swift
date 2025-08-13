//
//  ConfirmationButton.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.08.2025.
//

import SwiftUI

struct ConfirmButton<Label>: View where Label: View {
    
    let label: Label
    let action: @MainActor () -> Void

    @Environment(\.isEnabled) private var isEnabled
    
    init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.action = action
    }
    
    var body: some View {
        if #available(iOS 26, *) {
            Button(role: .confirm) {
                action()
            } label: {
                Image(systemName: "checkmark")
            }
            .disabled(!isEnabled)
        } else {
            Button {
                action()
            } label: {
                label
            }
            .disabled(!isEnabled)
        }
    }
}
