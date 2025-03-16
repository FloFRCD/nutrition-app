//
//  DetailedRecipe.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 16/03/2025.
//

import Foundation
struct DetailedRecipe: Codable, Identifiable {
    var id = UUID()
    let name: String
    let description: String
    let type: String
    let ingredients: [Ingredient]
    let nutritionFacts: NutritionFacts
    let instructions: [String]
    
    struct Ingredient: Codable, Identifiable {
        var id = UUID()
        let name: String
        let quantity: Double
        let unit: String
        
        // CodingKeys pour exclure id lors du décodage
        enum CodingKeys: String, CodingKey {
            case name, quantity, unit
        }
    }
    
    struct NutritionFacts: Codable {
        let calories: Int
        let proteins: Double
        let carbs: Double
        let fats: Double
        let fiber: Double
    }
    
    // CodingKeys pour exclure id lors du décodage
    enum CodingKeys: String, CodingKey {
        case name, description, type, ingredients, nutritionFacts, instructions
    }
}

struct DetailedRecipesResponse: Codable {
    let detailed_recipes: [DetailedRecipe]
}
