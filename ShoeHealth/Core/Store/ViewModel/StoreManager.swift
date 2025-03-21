//
//  StoreManager.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 03.09.2024.
//

import Foundation
import StoreKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "StoreManager")

typealias Transaction = StoreKit.Transaction

public enum StoreError: Error {
    case failedVerification
}

enum ProductID: String, CaseIterable {
    case lifetime = "com.robertbasamac.shoehealth.fullaccess.lifetime" // Non-consumable
    case yearlySubscription = "com.robertbasamac.shoehealth.fullaccess.subscription.yearly" // Auto-renewable
    case monthlySubscription = "com.robertbasamac.shoehealth.fullaccess.subscription.monthly" // Auto-renewable
}

// MARK: - StoreManager

final class StoreManager: ObservableObject {
    
    static let shared = StoreManager()
    
    private let defaults = UserDefaults(suiteName: System.AppGroups.shoeHealth)
    
    @Published private(set) var lifetimeProduct: Product?
    @Published private(set) var subscriptionProducts: [Product] = []
    
    @Published private(set) var purchasedProducts: [Product] = []
    
    @Published private(set) var hasFullAccess: Bool {
        didSet {
            defaults?.set(hasFullAccess, forKey: "IS_PREMIUM_USER")
        }
    }
    
    @Published private(set) var expirationDate: Date?
    @Published private(set) var willRenew: Bool = false
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    // MARK: Premium Features
    
    struct PremiumFeature: Identifiable, Hashable {
        let id = UUID()
        let title: String
    }
    
    /// - `shoesLimit`: an Int indicating the number of shoes allowed for free subscription
    static let shoesLimit: Int = 5
    
    /// - `premiumFeatures`: an array of features that the user can get when purchasing a subscription
    static let premiumFeatures: [PremiumFeature] = [
        PremiumFeature(title: "Unlimited Shoes"),
        PremiumFeature(title: "Default Shoes for multiple run types")
    ]
    
    // MARK: - init and deinit
    
    private init() {
        self.hasFullAccess = defaults?.bool(forKey: "IS_PREMIUM_USER") ?? false
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Store Methods
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task(priority: .background) {
            for await result in Transaction.updates {
                logger.debug("New transaction received.")
                
                do {
                    let transaction = try self.checkVerified(result)
                    
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    logger.error("Transaction failed verification.")
                }
            }
        }
    }
    
    @MainActor
    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: ProductID.allCases.map { $0.rawValue })
            logger.debug("\(storeProducts.count) products received from App Store")
            
            for product in storeProducts {
                switch product.id {
                case ProductID.lifetime.rawValue:
                    lifetimeProduct = product
                case ProductID.monthlySubscription.rawValue, ProductID.yearlySubscription.rawValue:
                    subscriptionProducts.append(product)
                default:
                    break
                }
            }
            
            subscriptionProducts = sortByPrice(subscriptionProducts)
            
            logger.debug("Successfully loaded products: Lifetime: \(self.lifetimeProduct?.displayName ?? "None"), Subscriptions: \(self.subscriptionProducts.map { $0.displayName })")
        } catch {
            logger.error("Failed product request from the App Store server. \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            await updateCustomerProductStatus()
            
            await transaction.finish()
        case .userCancelled:
            logger.debug("User cancelled the purchase.")
        case .pending:
            logger.debug("The purchase is pending.")
        default:
            logger.debug("Something went wrong while purchasing \"\(product.displayName)\".")
            break
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var newPurchasedProducts: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .nonConsumable:
                    if let product = lifetimeProduct {
                        if transaction.productID == product.id {
                            logger.debug("\"\(product.displayName)\" product purchased.")
                            
                            newPurchasedProducts.append(product)
                        }
                    }
                case .autoRenewable:
                    guard transaction.revocationDate == nil else {
                        continue
                    }
                    
                    if let product = subscriptionProducts.first(where: { $0.id == transaction.productID }) {
                        logger.debug("\"\(product.displayName)\" subscription purchased.")
                        
                        newPurchasedProducts.append(product)
                        
                        guard let expirationDate = transaction.expirationDate else {
                            continue
                        }
                        
                        self.expirationDate = expirationDate                        
                    }
                default:
                    break
                }
            } catch {
                logger.error("Transaction verification failed.")
            }
        }
        
        self.purchasedProducts = Array(Set(newPurchasedProducts))
        self.hasFullAccess = !self.purchasedProducts.isEmpty
    }
    
    func isPurchased(_ product: Product) -> Bool {
        return purchasedProducts.contains(product)
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func getBadge() -> String {
        if let product = lifetimeProduct {
            if isPurchased(product) {
                return "Lifetime"
            }
        }
        
        var badge: String = "Free"
        
        for product in purchasedProducts {
            if product.type == .nonRenewable {
                return "Lifetime"
            } else if product.type == .autoRenewable {
                badge = "Subscribed"
                continue
            }
        }
        
        return badge
    }
    
    // MARK: - Helper Methods
    
    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price > $1.price })
    }
}
