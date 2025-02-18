//
//  Subwcription.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation

enum SubscriptionTier: String, Codable {
    case free = "Gratuit"
    case premium = "Premium"
    case premiumPlus = "Premium+"
}

struct SubscriptionFeature: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var tier: SubscriptionTier
}
