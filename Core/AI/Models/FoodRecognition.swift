//
//  FoodRecognition.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct FoodRecognition {
    let name: String
    let confidence: Double
    let nutritionInfo: NutritionInfo
    
    init(name: String, confidence: Double, nutritionInfo: NutritionInfo) {
        self.name = name
        self.confidence = confidence
        self.nutritionInfo = nutritionInfo
    }
}
