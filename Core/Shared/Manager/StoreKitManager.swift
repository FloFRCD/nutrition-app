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
        do {
            let productIDs = [
                PremiumProductID.weekly.rawValue,
                PremiumProductID.monthly.rawValue,
                PremiumProductID.yearly.rawValue
            ]
            let storeProducts = try await Product.products(for: productIDs)
            await MainActor.run {
                self.products = storeProducts
            }

        } catch {
            print("❌ Erreur de chargement des produits : \(error)")
        }
    }

    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verificationResult):
            if case .verified(_) = verificationResult {
                print("✅ Achat vérifié : \(product.id)")
                updateSubscriptionTier(for: product.id)
            } else {
                print("❌ Achat non vérifié")
            }

        case .userCancelled:
            print("⛔️ Annulé par l'utilisateur")
        case .pending:
            print("⏳ Paiement en attente")
        default:
            break
        }
    }

    
    private func updateSubscriptionTier(for productID: String) {
        switch productID {
        case PremiumProductID.weekly.rawValue:
            currentSubscription = .weekly
        case PremiumProductID.monthly.rawValue:
            currentSubscription = .monthly
        case PremiumProductID.yearly.rawValue:
            currentSubscription = .yearly
        default:
            currentSubscription = .free
        }
    }
    
    func restorePurchases() async throws {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                updateSubscriptionTier(for: transaction.productID)
            default:
                continue
            }
        }
    }

#if DEBUG
var overridePremium: Bool {
    UserDefaults.standard.bool(forKey: "debug_premium_override")
}

var effectiveSubscription: SubscriptionTier {
    overridePremium ? .monthly : currentSubscription
}
#else
var effectiveSubscription: SubscriptionTier {
    currentSubscription
}
#endif


}
