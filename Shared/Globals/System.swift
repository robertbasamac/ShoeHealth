//
//  System.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 21.03.2025.
//

import Foundation


struct System {
    
    // MARK: - App Links
    
    struct AppLinks {
        static let termsOfService = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
        static let privacyPolicy = URL(string: "https://github.com/robertbasamac/ShoeHealth/blob/master/PRIVACY_POLICY.md")!
    }
    
    // MARK: - App Groups
    
    struct AppGroups {
        static let shoeHealth = "group.com.robertbasamac.ShoeHealth"
    }
}

