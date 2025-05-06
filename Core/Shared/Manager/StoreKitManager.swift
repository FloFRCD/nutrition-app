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
class StoreKitManager: NSObject, ObservableObject {
    static let shared = StoreKitManager()

    @Published var currentSubscription: SubscriptionTier = .free
    @Published var isPremiumUser: Bool = false
    @Published var products: [Product] = []

    enum SubscriptionTier {
        case free, weekly, monthly, yearly
    }

    override init() {
        super.init()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_eUkrIamUmldMUFfhqIGDCEQOGvk")
        Purchases.shared.delegate = self

        // Vérifie immédiatement le cache local
        if let cachedInfo = Purchases.shared.cachedCustomerInfo, cachedInfo.entitlements["PREMIUM"]?.isActive == true {
            updatePremiumStatus(with: cachedInfo)
        }

        // Puis recharge tranquillement en arrière-plan
        Purchases.shared.getCustomerInfo { info, error in
            if let info = info {
                self.updatePremiumStatus(with: info)
            }
        }
    }
    
    var isReviewOrSandbox: Bool {
        #if DEBUG
        return true // Build Xcode local
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
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
            print("❌ Erreur chargement produits StoreKit 2 : \(error)")
        }
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
        isPremiumUser = false
    }

    func handleSuccessfulPurchase(for productID: String) {
        updateSubscriptionTier(for: productID)
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
        isPremiumUser = currentSubscription != .free
    }

    func updatePremiumStatus(with info: CustomerInfo) {
        print("📦 CustomerInfo reçu de RevenueCat :")
        print("Entitlements actifs : \(info.entitlements.active.keys)")

        guard let entitlement = info.entitlements.all["PREMIUM"], entitlement.isActive else {
            currentSubscription = .free
            isPremiumUser = false
            print("❌ Entitlement 'premium' inactif ou absent")
            return
        }

        let productId = entitlement.productIdentifier.lowercased()
        print("✅ Entitlement 'premium' actif via produit : \(productId)")

        if productId.contains("weekly") {
            currentSubscription = .weekly
        } else if productId.contains("monthly") {
            currentSubscription = .monthly
        } else if productId.contains("yearly") || productId.contains("annual") {
            currentSubscription = .yearly
        } else {
            currentSubscription = .free
        }

        isPremiumUser = true
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

extension StoreKitManager: @preconcurrency PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        print("🔄 Received updated CustomerInfo from RevenueCat")
        updatePremiumStatus(with: customerInfo)
    }
}



