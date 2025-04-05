//
//  Subwcription.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isPremiumUser: Bool = false

    #if DEBUG
    var isDevOverridePremium: Bool {
        UserDefaults.standard.bool(forKey: "devPremiumOverride")
    }

    var effectiveIsPremium: Bool {
        isDevOverridePremium || isPremiumUser
    }
    #else
    var effectiveIsPremium: Bool {
        isPremiumUser
    }
    #endif

    private init() {
        Task {
            await refreshSubscriptionStatus()
        }
    }

    func refreshSubscriptionStatus() async {
        do {
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    if transaction.productType == .autoRenewable && transaction.revocationDate == nil {
                        self.isPremiumUser = true
                        return
                    }
                case .unverified:
                    continue
                }
            }
            self.isPremiumUser = false
        } catch {
            print("❌ Erreur de vérification abonnement : \(error)")
            self.isPremiumUser = false
        }
    }
}

