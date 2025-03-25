//
//  Food.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

enum ServingUnit: String, Codable {
    case gram = "g"
    case milliliter = "ml"
    case piece = "pc"
}

struct Food: Identifiable, Codable {
    let id: UUID
    var name: String
    var calories: Int
    var proteins: Double
    var carbs: Double
    var fats: Double
    var fiber: Double
    var servingSize: Double
    var servingUnit: ServingUnit
    var image: String?
}

// Définition de FoodEntry
struct FoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var food: Food
    var quantity: Double
    var date: Date
    var mealType: MealType
    var source: FoodSource
    
    enum FoodSource: String, Codable {
        case manual = "Manuel"
        case foodPhoto = "Photo"
        case barcode = "Code-barre"
        case recipe = "Recette"
        case favorite = "Favori"
    }
    
    // Calcul des valeurs nutritionnelles pour cette entrée
    var nutritionValues: NutritionValues {
        let ratio = quantity / food.servingSize
        
        return NutritionValues(
            calories: Double(food.calories) * ratio,
            proteins: food.proteins * ratio,
            carbohydrates: food.carbs * ratio,
            fats: food.fats * ratio,
            fiber: food.fiber * ratio // À compléter si vous avez cette donnée pour Food
        )
    }
}

struct CIQUALFood: Codable, Identifiable {
    let alim_code: String
    let alim_nom_fr: String
    
    // Valeurs nutritionnelles principales
    let energie_kcal: Double?
    let proteines: Double?
    let glucides: Double?
    let lipides: Double?
    let sucres: Double?
    let fibres: Double?
    
    // Identifiant unique pour Identifiable
    var id: String { alim_code }
    
    // Nom formaté pour l'affichage
    var nom: String {
        return alim_nom_fr.capitalized
    }
    
    // Mappage des clés JSON
    enum CodingKeys: String, CodingKey {
        case alim_code
        case alim_nom_fr
        case energie_kcal = "energie_reglemen_ue_n_kcal_100_g"
        case proteines = "proteines_g_100_g"
        case glucides = "glucides_g_100_g"
        case lipides = "lipides_g_100_g"
        case sucres = "sucres_g_100_g"
        case fibres = "fibres_alimentaires_g_100_g"
    }
    
    func toFood(quantity: Double = 100) -> Food {
        return Food(
            id: UUID(),
            name: nom,
            calories: Int(energie_kcal ?? 0),
            proteins: proteines ?? 0,
            carbs: glucides ?? 0,
            fats: lipides ?? 0,
            fiber: fibres ?? 0,
            servingSize: 100,
            servingUnit: .gram,
            image: nil
        )
    }
    
    func createFoodEntryFromCIQUAL(ciqualFood: CIQUALFood, quantity: Double, mealType: MealType) -> FoodEntry {
        let food = ciqualFood.toFood()
        
        return FoodEntry(
            food: food,
            quantity: quantity,
            date: Date(),
            mealType: mealType,
            source: .manual // Ou créer une source spécifique comme .ciqual
        )
    }
}
