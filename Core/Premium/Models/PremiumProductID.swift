//
//  PremiumProductID.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation

enum PremiumProductID: String {
    case weekly = "FlorianFourcade.nutrition_app.Weekly"
    case monthly = "FlorianFourcade.nutrition_app.Monthly"
    case yearly = "FlorianFourcade.nutrition_app.Annual"
}


enum SubscriptionTier: String {
    case free
    case weekly
    case monthly
    case yearly
}
