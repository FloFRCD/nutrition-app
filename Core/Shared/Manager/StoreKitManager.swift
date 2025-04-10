//
//  StoreKitManager.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation
import StoreKit
import RevenueCat

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var currentSubscription: SubscriptionTier = .free
    @Published var products: [Product] = []

    enum SubscriptionTier {
        case free, weekly, monthly, yearly
    }

    private init() {}

    var isPremiumUser: Bool {
        currentSubscription != .free
    }

    func loadProducts() async {
        do {
            let ids = [
                "FlorianFourcade.nutrition_app.Weekly",
                "FlorianFourcade.nutrition_app.Monthly",
                "FlorianFourcade.nutrition_app.Annual"
            ]
            products = try await Product.products(for: ids)
        } catch {
            print("❌ Erreur chargement produits : \(error)")
        }
    }
    
    @MainActor
    func handleSuccessfulPurchase(for productID: String) {
        updateSubscriptionTier(for: productID)
        objectWillChange.send()
    }


    func checkActiveSubscription() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                print("✅ Abonnement actif : \(transaction.productID)")
                updateSubscriptionTier(for: transaction.productID)
                return
            default:
                continue
            }
        }
        print("❌ Aucun abonnement actif")
        currentSubscription = .free
    }

    private func updateSubscriptionTier(for productID: String) {
        switch productID {
        case "FlorianFourcade.nutrition_app.Weekly":
            currentSubscription = .weekly
        case "FlorianFourcade.nutrition_app.Monthly":
            currentSubscription = .monthly
        case "FlorianFourcade.nutrition_app.Annual":
            currentSubscription = .yearly
        default:
            currentSubscription = .free
        }
    }
    @MainActor
    func updatePremiumStatus(with info: CustomerInfo) {
        if info.entitlements.all["premium"]?.isActive == true {
            currentSubscription != .free
        } else {
            currentSubscription = .free
        }
    }

    
#if DEBUG
var overridePremium: Bool {
    UserDefaults.standard.bool(forKey: "debug_premium_override")
}

var effectiveSubscription: SubscriptionTier {
    overridePremium ? .monthly : .free
}
#else
var effectiveSubscription: SubscriptionTier {
    currentSubscription
}
#endif
}


