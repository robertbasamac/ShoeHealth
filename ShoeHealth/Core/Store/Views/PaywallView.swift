//
//  PaywallView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.10.2024.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var store: StoreManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showManagedSubscriptions: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let product = store.lifetimeProduct {
                    VStack(spacing: 12) {
                        ProductView(product) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.rect(cornerRadius: 25))
                            case .failure(_):
                                Image("ShoeHealth-unlimited")
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.rect(cornerRadius: 25))
                            case .unavailable:
                                Image("ShoeHealth-unlimited")
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.rect(cornerRadius: 25))
                            case .loading:
                                ProgressView()
                            @unknown default:
                                fatalError()
                            }
                        }
                        .productViewStyle(.large)
                        
                        if store.hasFullAccess {
                            if store.isPurchased(product) {
                                VStack(spacing: 12) {
                                    Text("You have lifetime access to all app features.")
                                    
                                    VStack(spacing: 4) {
                                        Text("If you have any active subscriptions, consider canceling them as they are no longer necessary.")
                                            .foregroundStyle(.white)
                                        
                                        Button {
                                            showManagedSubscriptions.toggle()
                                        } label: {
                                            Text("Manage subscriptions")
                                                .foregroundStyle(Color.theme.accent)
                                        }
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(Color.theme.accent)
                                .multilineTextAlignment(.center)
                                .manageSubscriptionsSheet(isPresented: $showManagedSubscriptions)
                            } else if let expirationDate = store.expirationDate {
                                VStack(spacing: 12) {
                                    Text("Subscribed until \(dateFormatter.string(from: expirationDate)).")
                                    
                                    Button {
                                        showManagedSubscriptions.toggle()
                                    } label: {
                                        Text("Manage subscriptions")
                                            .foregroundStyle(Color.theme.accent)
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(Color.theme.accent)
                                .multilineTextAlignment(.center)
                                .manageSubscriptionsSheet(isPresented: $showManagedSubscriptions)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    SubscriptionStoreView(subscriptions: store.subscriptionProducts) {
                        VStack(alignment: .leading, spacing: 8) {
                            featureItem(title: "Unlimited shoes")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 40)
                    }
                    .disabled(store.isPurchased(product))
                    .storeButton(.hidden, for: .cancellation)
                    .subscriptionStoreControlStyle(.prominentPicker)
                } else {
                    SubscriptionStoreView(subscriptions: store.subscriptionProducts)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
        }
    }
}

// MARK: - View Components

extension PaywallView {
    
    @ViewBuilder
    private func featureItem(title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(store.hasFullAccess ? Color.theme.accent : .gray)
            
            Text(title)
                .font(.callout)
                .italic()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PaywallView()
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager())
    }
}
