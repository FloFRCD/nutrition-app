//
//  NutritionInfo.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct NutritionInfo: Codable {
    var calories: Int
    var proteins: Double
    var carbs: Double
    var fats: Double
    var fiber: Double?
    var sugar: Double?
    
    var totalCalories: Int {
        return calories
    }
}
