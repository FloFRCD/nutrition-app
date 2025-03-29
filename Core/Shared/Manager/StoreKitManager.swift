//
//  StoreKitManager.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import StoreKit

class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var currentSubscription: SubscriptionTier = .free
    @Published var products: [Product] = []
    
    private init() {
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        // À implémenter avec StoreKit
    }
    
    func purchase(_ product: Product) async throws {
        // À implémenter avec StoreKit
    }
    
    func restorePurchases() async throws {
        // À implémenter avec StoreKit
    }
}
