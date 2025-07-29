//
//  StoreManaging.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 02.07.2025.
//

import Foundation
import StoreKit

protocol StoreManaging: Sendable {
    
    var isLoading: Bool { get set }
    var hasFullAccess: Bool { get set }
    var lifetimeProduct: Product? { get set }
    var subscriptionProducts: [Product] { get set }
    var purchasedProducts: [Product] { get set }
    var expirationDate: Date? { get set }
    var willRenew: Bool { get set }

    static var shoesLimit: Int { get }
    static var premiumFeatures: [StoreManager.PremiumFeature] { get }

    func loadProducts() async
    func purchase(_ product: Product) async throws
    func updateCustomerProductStatus() async
    func isPurchased(_ product: Product) -> Bool
    func getBadge() -> String
}
