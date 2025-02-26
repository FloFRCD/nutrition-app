//
//  MLService.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation
import UIKit

class MLService: ObservableObject {
    static let shared = MLService()
    
    private init() {}
    
    func recognizeFood(from image: UIImage) async throws -> [FoodRecognition] {
        // Cette fonction sera implémentée quand nous intégrerons CoreML
        // Pour l'instant, retournons des données de test
        return [
            FoodRecognition(
                name: "Pomme",
                confidence: 0.95,
                nutritionInfo: NutritionInfo(
                    calories: 52,
                    proteins: 0.3,
                    carbs: 14.0,
                    fats: 0.2,
                    fiber: 2.4
                )
            )
        ]
    }
}
