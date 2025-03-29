//
//  FoodScan.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

struct FoodScan: Identifiable, Codable {
    let id: UUID
    let foodName: String
    let nutritionInfo: NutritionInfo
    let date: Date
    let mealType: MealType
    
    init(id: UUID = UUID(), foodName: String, nutritionInfo: NutritionInfo, date: Date, mealType: MealType) {
        self.id = id
        self.foodName = foodName
        self.nutritionInfo = nutritionInfo
        self.date = date
        self.mealType = mealType
    }
}
