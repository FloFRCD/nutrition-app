//
//  SubscriptionViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 08/04/2025.
//

import Foundation
import RevenueCat

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var offerings: Offerings?
    @Published var customerInfo: CustomerInfo?

    init() {
        Task {
            await fetchOfferings()
            await fetchCustomerInfo()
        }
    }

    func fetchOfferings() async {
        do {
            let result = try await Purchases.shared.offerings()
            offerings = result
        } catch {
            print("Erreur lors de la récupération des offres : \(error)")
        }
    }

    func fetchCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            customerInfo = info
        } catch {
            print("Erreur CustomerInfo : \(error)")
        }
    }

    func purchase(_ package: Package) async {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            customerInfo = result.customerInfo
        } catch {
            print("Erreur d'achat : \(error)")
        }
    }

    func isPremiumUser() -> Bool {
        return customerInfo?.entitlements["premium"]?.isActive == true
    }
}
