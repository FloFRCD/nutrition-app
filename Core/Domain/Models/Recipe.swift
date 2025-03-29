//
//  Recipe.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 26/02/2025.
//

import Foundation

// MARK: - Recipe Model
struct Recipe: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let ingredients: [RecipeIngredient]
    let instructions: [String]
    let prepTime: Int // en minutes
    let cookTime: Int // en minutes
    let servings: Int
    
    // Propriétés nutritionnelles calculées
    var nutritionValues: NutritionValues?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        ingredients: [RecipeIngredient],
        instructions: [String],
        prepTime: Int,
        cookTime: Int,
        servings: Int,
        nutritionValues: NutritionValues? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.nutritionValues = nutritionValues
    }
    
    var totalTime: Int {
        return prepTime + cookTime
    }
}

// MARK: - Recipe Ingredient
struct RecipeIngredient: Identifiable, Codable {
    let id: UUID
    let name: String
    let quantity: Double
    let unit: IngredientUnit
    
    // Identifiant OpenFoodFacts (sera rempli après l'association)
    var foodFactsID: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: IngredientUnit,
        foodFactsID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.foodFactsID = foodFactsID
    }
    
    // Conversion en grammes pour faciliter le calcul nutritionnel
    func quantityInGrams() -> Double? {
        switch unit {
        case .gram:
            return quantity
        case .kilogram:
            return quantity * 1000
        case .milliliter:
            // Pour les liquides, on considère une densité de 1g/ml pour simplifier
            return quantity
        case .liter:
            return quantity * 1000
        case .tablespoon:
            // Approximation moyenne (dépend du contenu)
            return quantity * 15
        case .teaspoon:
            // Approximation moyenne (dépend du contenu)
            return quantity * 5
        case .piece:
            // Impossible de déterminer sans connaître le poids moyen
            return nil
        case .cup:
            // Approximation moyenne (dépend du contenu)
            return quantity * 240
        }
    }
}

// MARK: - Ingredient Unit
enum IngredientUnit: String, Codable, CaseIterable {
    case gram = "g"
    case kilogram = "kg"
    case milliliter = "ml"
    case liter = "l"
    case tablespoon = "tbsp"
    case teaspoon = "tsp"
    case piece = "pc"
    case cup = "cup"
    
    var description: String {
        switch self {
        case .gram: return "grammes"
        case .kilogram: return "kilogrammes"
        case .milliliter: return "millilitres"
        case .liter: return "litres"
        case .tablespoon: return "cuillères à soupe"
        case .teaspoon: return "cuillères à café"
        case .piece: return ""
        case .cup: return "tasses"
        }
    }
}
