//
//  NutritionInfo.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct NutritionValues: Codable {
    let calories: Double
    let proteins: Double
    let carbohydrates: Double
    let fats: Double
    let fiber: Double
    
    init(calories: Double, proteins: Double, carbohydrates: Double, fats: Double, fiber: Double) {
        self.calories = calories
        self.proteins = proteins
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.fiber = fiber
    }
}

// Pour la compatibilité avec le code existant qui utilise NutritionInfo
struct NutritionInfo: Codable {
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
    let fiber: Double
    
    // Convertir NutritionInfo en NutritionValues
    func toNutritionValues(fiber: Double = 0) -> NutritionValues {
        return NutritionValues(
            calories: calories,
            proteins: proteins,
            carbohydrates: carbs,
            fats: fats,
            fiber: fiber
        )
    }
}
