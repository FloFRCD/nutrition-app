//
//  Food.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

enum ServingUnit: String, Codable, CaseIterable, Identifiable {
    case gram = "g"
    case milliliter = "mL"
    case piece = "pièce"
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .gram: return "g"
        case .milliliter: return "mL"
        case .piece: return "pièce"
        }
    }
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

struct FoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var food: Food
    var quantity: Double
    var date: Date
    var mealType: MealType
    var source: FoodSource
    let unit: String  // ✅ Unité ("g", "ml", "pc")

    init(id: UUID = UUID(), food: Food, quantity: Double, date: Date, mealType: MealType, source: FoodSource, unit: String) {
        self.id = id
        self.food = food
        self.quantity = quantity
        self.date = date
        self.mealType = mealType
        self.source = source
        self.unit = unit
    }

    enum FoodSource: String, Codable {
        case manual = "Manuel"
        case foodPhoto = "Photo"
        case barcode = "Code-barre"
        case recipe = "Recette"
        case favorite = "Favori"
    }

    // ✅ Ajoute `unit` ici pour l’encodage/décodage automatique
    enum CodingKeys: String, CodingKey {
        case id, food, quantity, date, mealType, source, unit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        food = try container.decode(Food.self, forKey: .food)
        quantity = try container.decode(Double.self, forKey: .quantity)
        mealType = try container.decode(MealType.self, forKey: .mealType)
        source = try container.decode(FoodSource.self, forKey: .source)
        unit = try container.decodeIfPresent(String.self, forKey: .unit) ?? "g" // fallback

        // ✅ Gestion intelligente de la date
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let formatter = ISO8601DateFormatter()
            if let parsedDate = formatter.date(from: dateString) {
                date = parsedDate
            } else {
                throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Cannot parse date string")
            }
        } else if let timestamp = try? container.decode(Double.self, forKey: .date) {
            date = Date(timeIntervalSince1970: timestamp)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date is neither string nor double")
        }
    }

    // Calcul des macros pour cette entrée
    var nutritionValues: NutritionValues {
        return NutritionValues(
            calories: Double(food.calories) * quantity,
            proteins: food.proteins * quantity,
            carbohydrates: food.carbs * quantity,
            fats: food.fats * quantity,
            fiber: food.fiber * quantity
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

struct CustomFood: Codable, Identifiable {
    let id: UUID
    let name: String
    let calories: Int
    let proteins: Double
    let carbs: Double
    let fats: Double
    let fiber: Double
    let servingSize: Double
    let servingUnit: ServingUnit
    
    init(from food: Food) {
        self.id = food.id
        self.name = food.name
        self.calories = food.calories
        self.proteins = food.proteins
        self.carbs = food.carbs
        self.fats = food.fats
        self.fiber = food.fiber
        self.servingSize = food.servingSize
        self.servingUnit = food.servingUnit
    }
    
    func toFood() -> Food {
        return Food(
            id: id,
            name: name,
            calories: calories,
            proteins: proteins,
            carbs: carbs,
            fats: fats,
            fiber: fiber,
            servingSize: servingSize,
            servingUnit: servingUnit,
            image: nil
        )
    }
}

extension Food {
    init(from ciqual: CIQUALFood) {
        let id = UUID()
        let name = ciqual.nom
        
        var calories = ciqual.energie_kcal ?? 0
        var proteins = ciqual.proteines ?? 0
        var carbs = ciqual.glucides ?? 0
        var fats = ciqual.lipides ?? 0
        let fiber = ciqual.fibres ?? 0
        
        let knownCalories = calories > 0
        let knownProteins = proteins > 0
        let knownCarbs = carbs > 0
        let knownFats = fats > 0
        
        // Complétion intelligente + logs
        if !knownCalories && knownProteins && knownCarbs && knownFats {
            calories = (proteins * 4 + carbs * 4 + fats * 9).rounded()
            print("✅ [CIQUAL] Calories complétées automatiquement pour '\(name)': \(Int(calories)) kcal")
        } else if knownCalories && !knownFats && knownProteins && knownCarbs {
            fats = max(0, (calories - (proteins * 4) - (carbs * 4)) / 9)
            print("✅ [CIQUAL] Lipides complétés automatiquement pour '\(name)': \(String(format: "%.2f", fats)) g")
        } else if knownCalories && knownFats && !knownCarbs && knownProteins {
            carbs = max(0, (calories - (proteins * 4) - (fats * 9)) / 4)
            print("✅ [CIQUAL] Glucides complétés automatiquement pour '\(name)': \(String(format: "%.2f", carbs)) g")
        } else if knownCalories && knownFats && knownCarbs && !knownProteins {
            proteins = max(0, (calories - (carbs * 4) - (fats * 9)) / 4)
            print("✅ [CIQUAL] Protéines complétées automatiquement pour '\(name)': \(String(format: "%.2f", proteins)) g")
        }
        
        self.init(
            id: id,
            name: name,
            calories: Int(calories.rounded()),
            proteins: proteins,
            carbs: carbs,
            fats: fats,
            fiber: fiber,
            servingSize: 100,
            servingUnit: .gram,
            image: nil
        )
    }
}

struct NutriaFood: Identifiable, Codable {
    let id: String                   // ID Firestore ou UUID local
    let canonicalName: String       // Ex: "Kinder Schoko-Bon"
    let normalizedName: String      // Ex: "kinder schoko bon"
    let brand: String?              // Ex: "Ferrero"
    let normalizedBrand: String?    // Ex: "ferrero"
    let isGeneric: Bool             // true si pas de marque
    let servingSize: Double         // Ex: 100 ou 1
    let servingUnit: String         // Ex: "g", "ml", "pc"
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
    let fiber: Double
    let source: String              // Ex: "gpt-4o-mini"
    let createdAt: Date
}

