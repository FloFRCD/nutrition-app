//
//  AIResponse.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

// Structures pour le parsing de la réponse JSON
struct AIMealPlanResponse: Codable {
    let days: [AIDay]
}

struct AIDay: Codable {
    let date: String
    let meals: [AIMeal]
}

struct AIMeal: Codable {
    let name: String
    let type: String
    let calories: Int
    let ingredients: [AIIngredient]
}

struct AIIngredient: Codable {
    let name: String
    let quantity: Double
    let unit: String
}
