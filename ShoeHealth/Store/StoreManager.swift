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
    
    @Published private(set) var lifetimeProduct: Product?
    @Published private(set) var subscriptionProducts: [Product] = []
    
    @Published private(set) var purchasedProducts: [Product] = []
    @Published private(set) var hasFullAccess: Bool = false
    
    @Published private(set) var status: String = ""
    @Published private(set) var info: String = ""
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()
        
        Task {
            // During store initialization, request products from the App Store.
            await requestProducts()
            
            // Check the customer's purchase status.
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    logger.debug("New transaction received.")
                    
                    // Deliver products to the user.
                    await self.updateCustomerProductStatus()
                    
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification.")
                }
            }
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            // Request products from the App Store
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
        // Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)
            
            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            
            // Always finish a transaction.
            await transaction.finish()
        case .userCancelled:
            logger.debug("User cancelled the purchase.")
        case .pending:
            logger.debug("The purchase is pending.")
        default:
            break
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedProducts: [Product] = []
        var isFullAccessPurchased = false
        
        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                // Check if the user has purchased the full access product
                switch transaction.productType {
                case .nonConsumable:
                    if let product = lifetimeProduct {
                        if transaction.productID == product.id {
                            logger.debug("\"\(product.displayName)\" product purchased.")
                            
                            purchasedProducts.append(product)
                            isFullAccessPurchased = true
                        }
                    }
                case .autoRenewable:
                    if let product = subscriptionProducts.first(where: { $0.id == transaction.productID }) {
                        logger.debug("\"\(product.displayName)\" subscription purchased.")
                        
                        purchasedProducts.append(product)
                        isFullAccessPurchased = true
                    }
                default:
                    break
                }
            } catch {
                logger.error("Transaction verification failed.")
            }
        }
        
        //        if fullAccessPurchased, let lifetimeProduct = lifetimeProduct {
        //            if purchasedProducts.contains(lifetimeProduct) {
        //                logger.debug("User has purchased the lifetime product, removing subscriptions.")
        //                subscriptionProducts.removeAll() // Subscriptions become unavailable
        //            }
        //        }
        
        // Update the store information with the purchased products.
        self.purchasedProducts = purchasedProducts
        self.hasFullAccess = isFullAccessPurchased
    }
    
    func isPurchased(_ product: Product) -> Bool {
        // Determine whether the user purchases a given product.
        return purchasedProducts.contains(product)
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    // MARK: - Helper Methods
    
    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price > $1.price })
    }
}
