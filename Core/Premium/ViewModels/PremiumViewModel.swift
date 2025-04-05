//
//  PremiumViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation
import StoreKit

@MainActor
class PremiumViewModel: ObservableObject {
    @Published var products: [Product] = []

    func loadProducts() async {
        do {
            let ids = PremiumProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: ids)
        } catch {
            print("❌ Erreur de chargement des produits : \(error)")
        }
    }

    func purchase(product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(_) = verification {
                    print("✅ Achat vérifié")
                    await SubscriptionManager.shared.refreshSubscriptionStatus()
                } else {
                    print("❌ Achat non vérifié")
                }
            case .userCancelled:
                print("❌ Achat annulé")
            case .pending:
                print("⏳ Achat en attente")
            default:
                break
            }
        } catch {
            print("❌ Erreur d'achat : \(error)")
        }
    }
}
