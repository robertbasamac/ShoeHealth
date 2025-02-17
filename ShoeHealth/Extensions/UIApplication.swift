//
//  UIApplication.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.05.2024.
//

import SwiftUI

extension UIApplication {
    
    static var connectedScenesCount: Int {
        return self.shared.connectedScenes.count
    }
    
    static var topSafeAreaInsets: CGFloat  {
        let scene = self.shared.connectedScenes.first as? UIWindowScene

        return scene?.windows.first?.safeAreaInsets.top ?? .zero
    }
    
    static var bottomSafeAreaInsets: CGFloat  {
        let scene = self.shared.connectedScenes.first as? UIWindowScene

        return scene?.windows.first?.safeAreaInsets.bottom ?? .zero
    }
    
    static var statusBarHeight: CGFloat  {
        let scene = self.shared.connectedScenes.first as? UIWindowScene

        return scene?.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? .zero
    }
    
    static var navigationBarHeight: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return 0
        }
        
        let navigationController = findNavigationController(from: rootViewController)
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        return navigationBarHeight
    }
    
    private static func findNavigationController(from viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for child in viewController.children {
            if let navigationController = findNavigationController(from: child) {
                return navigationController
            }
        }
        
        return nil
    }
}
