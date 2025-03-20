//
//  DetailedRecipe.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 16/03/2025.
//

import Foundation
struct DetailedRecipe: Codable, Identifiable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    let type: String
    let ingredients: [Ingredient]
    let nutritionFacts: NutritionFacts
    let instructions: [String]
    
    struct Ingredient: Codable, Identifiable, Equatable {
        var id = UUID()
        let name: String
        let quantity: Double
        let unit: String
        
        // CodingKeys pour exclure id lors du décodage
        enum CodingKeys: String, CodingKey {
            case name, quantity, unit
        }
        
        // Implémentation manuelle de Equatable pour ignorer l'id
        static func == (lhs: DetailedRecipe.Ingredient, rhs: DetailedRecipe.Ingredient) -> Bool {
            return lhs.name == rhs.name &&
                   lhs.quantity == rhs.quantity &&
                   lhs.unit == rhs.unit
        }
    }
    
    struct NutritionFacts: Codable, Equatable {
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
    
    // Implémentation manuelle de Equatable pour ignorer l'id
    static func == (lhs: DetailedRecipe, rhs: DetailedRecipe) -> Bool {
        return lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.type == rhs.type &&
               lhs.ingredients == rhs.ingredients &&
               lhs.nutritionFacts == rhs.nutritionFacts &&
               lhs.instructions == rhs.instructions
    }
}

struct DetailedRecipesResponse: Codable {
    let detailed_recipes: [DetailedRecipe]
}
