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
    case myFoodsSelector(mealType: MealType)
    case barcodeScanner(mealType: MealType)  // Nouvelle option
    
    var id: String {
        switch self {
        case .photoCapture(let mealType): return "photoCapture_\(mealType.rawValue)"
        case .recipeSelection(let mealType): return "recipeSelection_\(mealType.rawValue)"
        case .ingredientEntry(let mealType): return "ingredientEntry_\(mealType.rawValue)"
        case .customFoodEntry(let mealType): return "customFoodEntry_\(mealType.rawValue)"
        case .myFoodsSelector(let mealType): return "myFoodsSelector_\(mealType.rawValue)"
        case .barcodeScanner(let mealType): return "barcodeScanner_\(mealType.rawValue)"
        }
    }
}
