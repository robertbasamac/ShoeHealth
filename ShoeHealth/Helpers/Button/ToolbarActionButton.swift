//
//  ToolbarActionButton.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.10.2025.
//

import SwiftUI

enum ToolbarActionRole {
    
    case cancel
    case confirm
    
    var systemImageName: String {
        switch self {
        case .cancel: return "xmark"
        case .confirm: return "checkmark"
        }
    }
    
    var textLabel: String {
        switch self {
        case .cancel: return "Cancel"
        case .confirm: return "Done"
        }
    }
    
    var accessibilityLabel: String { textLabel }
}

struct ToolbarActionButton: View {
    
    let role: ToolbarActionRole
    let action: () -> Void
    
    init(_ role: ToolbarActionRole, action: @escaping () -> Void) {
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                Button(role: role == .cancel ? .cancel : .confirm) {
                    action()
                } label: {
                    Image(systemName: role.systemImageName)
                        .imageScale(.large)
                        .fontWeight(.medium)
                        .foregroundStyle(role == .cancel ? .white : .black)
                        .frame(width: 44, height: 44)
                        .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxLarge)
                }
                .glassEffect(role == .cancel ? .regular.interactive() : .regular.tint(.accent).interactive())
                .buttonBorderShape(.circle)
                .accessibilityLabel(role.accessibilityLabel)
            } else {
                Button {
                    action()
                } label: {
                    Text(role.textLabel)
                        .fontWeight(role == .confirm ? .semibold : .regular)
                        .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxLarge)
                }
                .accessibilityLabel(role.accessibilityLabel)
            }
        }
    }
}
