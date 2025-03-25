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
    
    // Gardez la conformité à Encodable par défaut
    
    // Implémentation personnalisée de Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Int.self, forKey: .calories)
        proteins = try container.decode(Double.self, forKey: .proteins)
        carbs = try container.decode(Double.self, forKey: .carbs)
        fats = try container.decode(Double.self, forKey: .fats)
        servingSize = try container.decode(Double.self, forKey: .servingSize)
        servingUnit = try container.decode(ServingUnit.self, forKey: .servingUnit)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        
        // Gestion spéciale pour fiber - utiliser 0.0 comme valeur par défaut si absent
        do {
            fiber = try container.decode(Double.self, forKey: .fiber)
        } catch DecodingError.keyNotFound {
            fiber = 0.0
            print("⚠️ Champ 'fiber' manquant dans les données Food - valeur par défaut 0.0 utilisée")
        } catch {
            throw error // Propager d'autres erreurs de décodage
        }
    }
    
    // Constructeur normal pour créer des instances en code
    init(id: UUID, name: String, calories: Int, proteins: Double, carbs: Double,
         fats: Double, fiber: Double, servingSize: Double, servingUnit: ServingUnit,
         image: String?) {
        self.id = id
        self.name = name
        self.calories = calories
        self.proteins = proteins
        self.carbs = carbs
        self.fats = fats
        self.fiber = fiber
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.image = image
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, calories, proteins, carbs, fats, fiber, servingSize, servingUnit, image
    }
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
    // Les autres propriétés...
    let alim_code: Int
    let alim_nom_fr: String
    
    // Valeurs nutritionnelles principales
    let energie__règlement_ue_n__1169_2011__kcal_100_g_: String?
    let protéines__n_x_6_25__g_100_g_: String?
    let glucides__g_100_g_: String?
    let lipides__g_100_g_: String?
    let sucres__g_100_g_: String?
    let fibres_alimentaires__g_100_g_: String?
    
    // ID pour Identifiable
    var id: String { return String(alim_code) }
    
    // Propriétés calculées pour conversion des valeurs
    var nom: String { alim_nom_fr }
    
    var energie_kcal: Double? {
        return convertStringToDouble(energie__règlement_ue_n__1169_2011__kcal_100_g_)
    }
    
    var proteines: Double? {
        return convertStringToDouble(protéines__n_x_6_25__g_100_g_)
    }
    
    var glucides: Double? {
        return convertStringToDouble(glucides__g_100_g_)
    }
    
    var lipides: Double? {
        return convertStringToDouble(lipides__g_100_g_)
    }
    
    var fibres: Double? {
        return convertStringToDouble(fibres_alimentaires__g_100_g_)
    }
    
    // Fonction utilitaire pour convertir les nombres français (avec virgule)
    private func convertStringToDouble(_ value: String?) -> Double? {
        guard let str = value, str != "-" else { return 0 }
        return Double(str.replacingOccurrences(of: ",", with: "."))
    }
}
