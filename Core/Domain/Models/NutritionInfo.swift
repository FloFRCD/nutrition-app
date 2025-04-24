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
    var fiber: Double
    
    enum CodingKeys: String, CodingKey {
        case calories, proteins, carbohydrates = "carbs", fats, fiber
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Décodage des champs obligatoires
        calories = try container.decode(Double.self, forKey: .calories)
        proteins = try container.decode(Double.self, forKey: .proteins)
        carbohydrates = try container.decode(Double.self, forKey: .carbohydrates)
        fats = try container.decode(Double.self, forKey: .fats)
        
        // Décodage de fiber avec valeur par défaut
        fiber = try container.decodeIfPresent(Double.self, forKey: .fiber) ?? 0.0
    }
    
    // Constructeur normal
    init(calories: Double, proteins: Double, carbohydrates: Double, fats: Double, fiber: Double = 0.0) {
        self.calories = calories
        self.proteins = proteins
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.fiber = fiber
    }
}

struct NutritionInfo: Codable {
    let servingSize: Double       // Ex: 100 ou 1
    let servingUnit: String       // "g", "ml" ou "pc"
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
    let fiber: Double
    
    enum CodingKeys: String, CodingKey {
        case servingSize
        case servingUnit
        case calories
        case proteins
        case carbs
        case fats
        case fiber
    }
    
    init(
        servingSize: Double = 100,
        servingUnit: String = "g",
        calories: Double,
        proteins: Double,
        carbs: Double,
        fats: Double,
        fiber: Double
    ) {
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.calories = calories
        self.proteins = proteins
        self.carbs = carbs
        self.fats = fats
        self.fiber = fiber
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Quantité et unité de portion (défaut = 100g)
        servingSize = try container.decodeIfPresent(Double.self, forKey: .servingSize) ?? 100
        servingUnit = try container.decodeIfPresent(String.self, forKey: .servingUnit) ?? "g"
        
        calories = try container.decode(Double.self, forKey: .calories)
        proteins = try container.decode(Double.self, forKey: .proteins)
        carbs = try container.decode(Double.self, forKey: .carbs)
        fats = try container.decode(Double.self, forKey: .fats)
        
        // Fibres : 10% des glucides par défaut
        fiber = try container.decodeIfPresent(Double.self, forKey: .fiber) ?? (carbs * 0.1)
    }
}

