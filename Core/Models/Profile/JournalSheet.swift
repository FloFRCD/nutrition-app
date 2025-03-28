//
//  JournalSheet.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import Foundation

enum JournalSheet: Identifiable {
    case photoCapture(mealType: MealType)
    case recipeSelection(mealType: MealType)
    case ingredientEntry(mealType: MealType)
    case customFoodEntry(mealType: MealType)
    
    var id: String {
        switch self {
        case .photoCapture(let mealType):
            return "photo_\(mealType.rawValue)"
        case .recipeSelection(let mealType):
            return "recipe_\(mealType.rawValue)"
        case .ingredientEntry(let mealType):
            return "ingredient_\(mealType.rawValue)"
        case .customFoodEntry(mealType: let mealType):
            return "customFood_\(mealType.rawValue)"
        }
    }
}
