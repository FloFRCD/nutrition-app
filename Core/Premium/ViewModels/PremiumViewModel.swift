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
//    @Published var offerings: Offerings?
    @Published var offerings: Offerings? {
        didSet {
            print("🎁 Offres reçues : \(String(describing: offerings))")
        }
    }

    
    
    func loadProducts() async {
        do {
            print("🌀 Tentative de chargement des offerings...")
            let fetchedOfferings = try await Purchases.shared.offerings()
            print("✅ Offerings récupérés : \(fetchedOfferings.all.keys)")

            offerings = fetchedOfferings

            if let current = fetchedOfferings.current {
                print("📦 Offering 'current' trouvé : \(current.identifier)")
                print("🔍 Packages disponibles dans current :")

                for package in current.availablePackages {
                    print("• RevenueCat ID : \(package.identifier) | Store ID : \(package.storeProduct.productIdentifier)")
                }

                if current.availablePackages.isEmpty {
                    print("⚠️ Aucun package dans current.offering")
                }

            } else {
                print("❌ Aucun offering 'current' trouvé")
            }

        } catch {
            print("❌ Erreur lors du chargement des offerings : \(error.localizedDescription)")
        }
    }

    func purchase(package: Package) async {
        do {
            let (transaction, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            
            // ✅ Utilise immédiatement customerInfo fourni par le résultat de l'achat
            if customerInfo.entitlements.all["PREMIUM"]?.isActive == true {
                print("✅ Abonnement immédiatement actif (via résultat direct de purchase)")
                StoreKitManager.shared.updatePremiumStatus(with: customerInfo)
            } else {
                print("❌ Abonnement non actif immédiatement après achat")
            }
        } catch let error as NSError {
            if error.domain == "RevenueCat.ErrorCode", RevenueCat.ErrorCode(_bridgedNSError: error) == .purchaseCancelledError {
                print("❌ Achat annulé par l'utilisateur")
                return
            }
            print("❌ Erreur d’achat RevenueCat : \(error)")
        }
    }
}
