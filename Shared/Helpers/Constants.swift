//
//  Constants.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 10.08.2025.
//

import SwiftUI

struct Constants {
    
    static var cornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 15
        } else {
            return 10
        }
    }
    
    static var defaultCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 25
        } else {
            return 10
        }
    }
    
    static var presentationCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 25
        } else {
            return 20
        }
    }
    
    static let horizontalMargin: CGFloat = 20
}
