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

// Pour la compatibilité avec le code existant qui utilise NutritionInfo
struct NutritionInfo: Codable {
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
    let fiber: Double
    
    enum CodingKeys: String, CodingKey {
        case calories, proteins, carbs, fats, fiber
    }
    
    // Ajouter cet initialiser standard
    init(calories: Double, proteins: Double, carbs: Double, fats: Double, fiber: Double) {
        self.calories = calories
        self.proteins = proteins
        self.carbs = carbs
        self.fats = fats
        self.fiber = fiber
    }
    
    // Initialiser pour Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        calories = try container.decode(Double.self, forKey: .calories)
        proteins = try container.decode(Double.self, forKey: .proteins)
        carbs = try container.decode(Double.self, forKey: .carbs)
        fats = try container.decode(Double.self, forKey: .fats)
        
        // Utiliser une valeur par défaut (10% des glucides) si fiber est absent
        fiber = try container.decodeIfPresent(Double.self, forKey: .fiber) ?? {
            let carbs = try container.decode(Double.self, forKey: .carbs)
            return carbs * 0.1
        }()
    }
}
