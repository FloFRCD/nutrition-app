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

enum IngredientCategory: String, CaseIterable, Codable {
    case fruitsAndVegetables = "Fruits & Légumes"
    case proteins = "Protéines"
    case starches = "Féculents"
    case condimentsAndSpices = "Condiments & Épices"
    case grocery = "Épicerie"
    case other = "Autres"
}


extension String {
    var ingredientCategory: IngredientCategory {
        let lowerName = self.lowercased()
        
        // Fruits et légumes
        if ["pomme", "banane", "orange", "citron", "fraise", "framboise", "poire", "pêche", "abricot", "raisin",
            "tomate", "carotte", "poivron", "oignon", "ail", "échalote", "salade", "épinard", "courgette", "aubergine",
            "concombre", "brocoli", "chou", "champignon", "pomme de terre", "patate", "légume", "fruit"].contains(where: lowerName.contains) {
            return .fruitsAndVegetables
        }
        
        // Protéines
        if ["viande", "poulet", "dinde", "boeuf", "porc", "agneau", "veau", "jambon", "bacon", "saucisse",
            "poisson", "saumon", "thon", "crevette", "oeuf", "œuf", "lait", "yaourt", "fromage", "tofu",
            "légumineuse", "haricot", "lentille", "pois chiche"].contains(where: lowerName.contains) {
            return .proteins
        }
        
        // Féculents
        if ["riz", "pâte", "spaghetti", "nouille", "pomme de terre", "patate", "pain", "farine", "céréale",
            "couscous", "quinoa", "boulgour"].contains(where: lowerName.contains) {
            return .starches
        }
        
        // Condiments et épices
        if ["sel", "poivre", "huile", "vinaigre", "sauce", "moutarde", "mayonnaise", "ketchup", "épice",
            "herbe", "basilic", "thym", "romarin", "origan"].contains(where: lowerName.contains) {
            return .condimentsAndSpices
        }
        
        // Par défaut, mettre en épicerie
        return .grocery
    }
}
