//
//  Food.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

enum ServingUnit: String, Codable {
    case gram = "g"
    case milliliter = "ml"
    case piece = "pc"
}

struct Food: Identifiable, Codable {
    let id: UUID
    var name: String
    var calories: Int
    var proteins: Double
    var carbs: Double
    var fats: Double
    var servingSize: Double
    var servingUnit: ServingUnit
    var image: String?
}

// Définition de FoodEntry
struct FoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var food: Food
    var quantity: Double
    var date: Date
    var mealType: MealType
    var source: FoodSource
    
    enum FoodSource: String, Codable {
        case manual = "Manuel"
        case foodPhoto = "Photo"
        case barcode = "Code-barre"
        case recipe = "Recette"
        case favorite = "Favori"
    }
    
    // Calcul des valeurs nutritionnelles pour cette entrée
    var nutritionValues: NutritionValues {
        let ratio = quantity / food.servingSize
        
        return NutritionValues(
            calories: Double(food.calories) * ratio,
            proteins: food.proteins * ratio,
            carbohydrates: food.carbs * ratio,
            fats: food.fats * ratio,
            fiber: 0 // À compléter si vous avez cette donnée pour Food
        )
    }
}
