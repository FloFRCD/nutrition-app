//
//  ValidationHelper.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct ValidationHelper {
    static func isValidWeight(_ weight: Double) -> Bool {
        weight >= AppConstants.minimumWeight && weight <= AppConstants.maximumWeight
    }
    
    static func isValidAge(_ age: Int) -> Bool {
        age >= AppConstants.minimumAge && age <= AppConstants.maximumAge
    }
    
    static func isValidCalories(_ calories: Int) -> Bool {
        calories >= AppConstants.Nutrition.minCalories && calories <= AppConstants.Nutrition.maxCalories
    }
}
