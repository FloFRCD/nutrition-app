//
//  PremiumViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation
import StoreKit
import RevenueCat

@MainActor
class PremiumViewModel: ObservableObject {
    @Published var offerings: Offerings?
    
    func loadProducts() async {
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            print("❌ Erreur chargement offerings RevenueCat : \(error)")
        }
    }

    func purchase(package: Package) async {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.customerInfo.entitlements.all["premium"]?.isActive == true {
                print("✅ Abonnement actif via RevenueCat")
                // Met à jour ton app en conséquence
            } else {
                print("❌ Abonnement non actif")
            }
        } catch {
            print("❌ Erreur d’achat RevenueCat : \(error)")
        }
    }
}
