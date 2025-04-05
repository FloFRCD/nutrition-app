//
//  PremiumProductID.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation

enum PremiumProductID: String, CaseIterable {
    case weekly = "nutria.premium.weekly"
    case monthly = "nutria.premium.monthly"
    case yearly = "nutria.premium.yearly"
}


enum SubscriptionTier: String {
    case free
    case weekly
    case monthly
    case yearly
}
