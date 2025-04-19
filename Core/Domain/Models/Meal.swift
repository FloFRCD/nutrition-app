//
//  Meal.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Petit-déjeuner"
    case lunch = "Déjeuner"
    case dinner = "Dîner"
    case snack = "Collation"
}

struct Meal: Identifiable, Codable {
    let id: UUID
    var name: String
    var date: Date
    var foods: [Food]
    var type: MealType
    
    // Propriété calculée pour obtenir les calories totales
    var totalCalories: Int {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    // Autres propriétés calculées si nécessaire
    var totalProteins: Double {
        foods.reduce(0) { $0 + $1.proteins }
    }
    
    var totalCarbs: Double {
        foods.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFats: Double {
        foods.reduce(0) { $0 + $1.fats }
    }
    
    init(id: UUID = UUID(), name: String, date: Date, foods: [Food] = [], type: MealType) {
        self.id = id
        self.name = name
        self.date = date
        self.foods = foods
        self.type = type
    }
}

// Enum pour les restrictions alimentaires
enum DietaryRestriction: Codable, Hashable {
    case vegetarian
    case vegan
    case glutenFree
    case lactoseFree
    case sugarFree
    case diabete1
    case diabete2
    case other(String)

    var displayName: String {
        switch self {
        case .vegetarian: return "Végétarien"
        case .vegan: return "Végétalien"
        case .glutenFree: return "Sans gluten"
        case .lactoseFree: return "Sans lactose"
        case .sugarFree: return "Sans sucre"
        case .diabete1: return "Diabète de type 1"
        case .diabete2: return "Diabète de type 2"
        case .other(let value): return value.isEmpty ? "Autre" : value
        }
    }

    // Simule CaseIterable (pour un Picker ou liste fixe)
    static var predefinedCases: [DietaryRestriction] {
        [.vegetarian, .vegan, .glutenFree, .lactoseFree, .diabete1, .diabete2]
    }
}

extension DietaryRestriction {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "vegetarian": self = .vegetarian
        case "vegan": self = .vegan
        case "glutenFree": self = .glutenFree
        case "lactoseFree": self = .lactoseFree
        case "sugarFree": self = .sugarFree
        case "diabete1": self = .diabete1
        case "diabete2": self = .diabete2
        case "other":
            let value = try container.decode(String.self, forKey: .value)
            self = .other(value)
        default:
            self = .other(type)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .vegetarian:
            try container.encode("vegetarian", forKey: .type)
        case .vegan:
            try container.encode("vegan", forKey: .type)
        case .glutenFree:
            try container.encode("glutenFree", forKey: .type)
        case .lactoseFree:
            try container.encode("lactoseFree", forKey: .type)
        case .sugarFree:
            try container.encode("sugarFree", forKey: .type)
        case .diabete1:
            try container.encode("diabete1", forKey: .type)
        case .diabete2:
            try container.encode("diabete2", forKey: .type)
        case .other(let value):
            try container.encode("other", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

extension DietaryRestriction {
    static func from(string: String) -> DietaryRestriction {
        switch string.lowercased() {
        case "végétarien", "vegetarian": return .vegetarian
        case "végétalien", "vegan": return .vegan
        case "sans gluten", "glutenfree": return .glutenFree
        case "sans lactose", "lactosefree": return .lactoseFree
        case "sans sucre", "sugarfree": return .sugarFree
        case "diabète de type 1", "diabete1": return .diabete1
        case "diabète de type 2", "diabete2": return .diabete2
        default: return .other(string)
        }
    }
}

enum MealGoal: String, Codable, CaseIterable, Identifiable {
    case weightLossFast = "Perte de poids rapide"
    case weightLossModerate = "Perte de poids modérée"
    case muscleGain = "Prise de masse"
    case maintenance = "Maintien du poids"
    case detox = "Détox"
    case energyBoost = "Énergisant"

    var id: String { rawValue }
}

enum CuisineType: String, Codable, CaseIterable, Identifiable {
    case italian = "Italienne"
    case japanese = "Japonaise"
    case lebanese = "Libanaise"
    case mexican = "Mexicaine"
    case indian = "Indienne"
    case french = "Française"
    case other = "Autre"

    var id: String { rawValue }
}

enum MealFormat: String, Codable, CaseIterable, Identifiable {
    case salad = "Salade"
    case bowl = "Bowl"
    case soup = "Soupe"
    case wrap = "Wrap"
    case plate = "Assiette"
    case dessert = "Dessert"

    var id: String { rawValue }
}

struct MealPreferences: Codable {
    var bannedIngredients: [String]
    var preferredIngredients: [String]
    var defaultServings: Int
    var dietaryRestrictions: [DietaryRestriction]
    var mealTypes: [MealType]
    var recipesPerType: Int
    var userProfile: UserProfile
    var otherRestriction: String?
    var mealGoal: MealGoal?
    var cuisineTypes: [CuisineType]?
    var mealFormats: [MealFormat]?
    var promptOverride: String?
    var isPromptOverrideEnabled: Bool = false

    init(
        bannedIngredients: [String] = [],
        preferredIngredients: [String] = [],
        defaultServings: Int = 1,
        dietaryRestrictions: [DietaryRestriction] = [],
        mealTypes: [MealType] = [],
        recipesPerType: Int = 2,
        userProfile: UserProfile,
        otherRestriction: String = "",
        mealGoal: MealGoal? = nil,
        cuisineTypes: [CuisineType]? = nil,
        mealFormats: [MealFormat]? = nil,
        promptOverride: String? = nil,
        isPromptOverrideEnabled: Bool = false
    ) {
        self.bannedIngredients = bannedIngredients
        self.preferredIngredients = preferredIngredients
        self.defaultServings = defaultServings
        self.dietaryRestrictions = dietaryRestrictions
        self.mealTypes = mealTypes
        self.recipesPerType = recipesPerType
        self.userProfile = userProfile
        self.otherRestriction = otherRestriction
        self.mealGoal = mealGoal
        self.cuisineTypes = cuisineTypes
        self.mealFormats = mealFormats
        self.promptOverride = promptOverride
        self.isPromptOverrideEnabled = isPromptOverrideEnabled

        if !userProfile.dietaryRestrictions.isEmpty {
            var updatedRestrictions = self.dietaryRestrictions

            for restriction in userProfile.dietaryRestrictions {
                let parsed = DietaryRestriction.from(string: restriction)

                if case .other(let value) = parsed,
                   DietaryRestriction.predefinedCases.contains(where: { $0.displayName == value }) == false {
                    if !self.bannedIngredients.contains(value) {
                        self.bannedIngredients.append(value)
                    }
                } else {
                    if !updatedRestrictions.contains(parsed) {
                        updatedRestrictions.append(parsed)
                    }
                }
            }

            self.dietaryRestrictions = updatedRestrictions
        }
    }

    var aiPromptFormat: String {
            let bulletPoints = mealTypes.map { "- \(recipesPerType) plats de \($0.rawValue)" }.joined(separator: "\n")
            let mealTypesList = mealTypes.map { $0.rawValue }.joined(separator: ", ")

            let restrictionList = dietaryRestrictions.map { $0.displayName }
            var fullRestrictions = restrictionList
            if let other = otherRestriction, !other.trimmingCharacters(in: .whitespaces).isEmpty {
                fullRestrictions.append(other)
            }
            let restrictionsText = fullRestrictions.joined(separator: ", ")

            let nutritionalText = NutritionCalculator.shared.generateNutritionalPromptText(for: userProfile)

            var promptText = """
            Tu es un chef cuisinier renommé spécialisé en nutrition.

            Génère-moi exactement :
            \(bulletPoints)

            Vérifie qu'il y a bien \(recipesPerType * mealTypes.count) plats au total.

            Les types de repas à générer sont : \(mealTypesList).

            CONTRAINTES SUPPLÉMENTAIRES :
            """

            if isPromptOverrideEnabled,
               let override = promptOverride,
               !override.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                promptText += "\n\(override.trimmingCharacters(in: .whitespacesAndNewlines))"
            } else {
                promptText += """
                \n- Restrictions alimentaires : \(restrictionsText)
                - Ingrédients à ne surtout pas utiliser : \(bannedIngredients.joined(separator: ", "))
                - Ingrédients à utiliser en priorité : \(preferredIngredients.joined(separator: ", "))
                """

                if let mealGoal {
                    promptText += "\n- Objectif spécifique des repas : \(mealGoal.rawValue)"
                }

                if let cuisineTypes, !cuisineTypes.isEmpty {
                    promptText += "\n- Origine culinaire souhaitée : \(cuisineTypes.map { $0.rawValue }.joined(separator: ", "))"
                }

                if let mealFormats, !mealFormats.isEmpty {
                    promptText += "\n- Format des plats : \(mealFormats.map { $0.rawValue }.joined(separator: ", "))"
                }
            }

            promptText += "\n\n\(nutritionalText)\n"

            promptText += """
            Format requis pour chaque suggestion :
            1. Nom du repas (max 10 mots)
            2. Description brève (max 15 mots)
            3. Type de repas (un des types mentionnés ci-dessus)

            RÉPONDS UNIQUEMENT AU FORMAT JSON SUIVANT (pas de texte avant ou après) :
            {
              "meal_suggestions": [
                {
                  "name": "Nom du repas",
                  "description": "Brève description",
                  "type": "Type de repas"
                }
              ]
            }
            """

            print("===== DÉBUT DU PROMPT ENVOYÉ À L'API =====")
            print(promptText)
            print("===== FIN DU PROMPT ENVOYÉ À L'API =====")

            return promptText
        }


    func printDebugPrompt() {
        print("------- DEBUT DU PROMPT ---------")
        print(aiPromptFormat)
        print("------- FIN DU PROMPT ---------")
    }

    func validateMeal(_ meal: Meal) -> Bool {
        for food in meal.foods {
            for banned in bannedIngredients {
                if food.name.lowercased().contains(banned.lowercased()) {
                    print("⚠️ Ingrédient banni trouvé: \(food.name) contient \(banned)")
                    return false
                }
            }
        }
        return true
    }
}


extension MealPreferences {
    // Fonction qui calcule les besoins nutritionnels en fonction du profil utilisateur
    func calculateNutritionalNeeds(userProfile: UserProfile) -> String {
        // Calcul du métabolisme basal (BMR) avec la formule de Mifflin-St Jeor
        let isMale = userProfile.gender == .male
        let bmr = 10 * userProfile.weight + 6.25 * userProfile.height - 5 * Double(userProfile.age) + (isMale ? 5 : -161)
        
        // Facteur d'activité
        var activityFactor = 1.2 // Sédentaire par défaut
        switch userProfile.activityLevel {
        case .sedentary:
            activityFactor = 1.2
        case .lightlyActive:
            activityFactor = 1.375
        case .moderatelyActive:
            activityFactor = 1.55
        case .veryActive:
            activityFactor = 1.725
        case .extraActive:
            activityFactor = 1.9
        }
        
        // Besoins caloriques totaux (TDEE)
        let tdee = bmr * activityFactor
        
        // Ajustement selon l'objectif
        var targetCalories = tdee
        var proteinPerKg = 1.6
        var fatPerKg = 1.0
        
        switch userProfile.fitnessGoal {
        case .loseWeight:
            targetCalories = tdee * 0.8 // Déficit de 20%
            proteinPerKg = 2.2 // Protéines plus élevées pour préserver la masse musculaire
            fatPerKg = 0.8
        case .maintainWeight:
            targetCalories = tdee
            proteinPerKg = 1.6
            fatPerKg = 1.0
        case .gainMuscle:
            targetCalories = tdee * 1.15 // Surplus de 15%
            proteinPerKg = 2.0
            fatPerKg = 1.0
        }
        
        // Calcul des macronutriments quotidiens
        let dailyProtein = userProfile.weight * proteinPerKg
        let dailyFat = userProfile.weight * fatPerKg
        // Protéines et graisses en calories
        let proteinCalories = dailyProtein * 4
        let fatCalories = dailyFat * 9
        // Calcul des glucides pour compléter les calories
        let carbCalories = targetCalories - proteinCalories - fatCalories
        let dailyCarbs = carbCalories / 4
        
        // Répartition par repas
        let breakfastCalories = targetCalories * 0.25
        let lunchCalories = targetCalories * 0.35
        let dinnerCalories = targetCalories * 0.3
        let snackCalories = targetCalories * 0.1
        
        // Construction de la chaîne de caractères pour le prompt
        return """
        Informations nutritionnelles personnalisées:
        - Métabolisme basal: \(Int(bmr)) calories/jour
        - Besoins caloriques totaux: \(Int(tdee)) calories/jour
        - Objectif calorique quotidien: \(Int(targetCalories)) calories/jour selon l'objectif de \(userProfile.fitnessGoal.rawValue)
        
        Besoins quotidiens en macronutriments:
        - Protéines: \(Int(dailyProtein))g (\(Int(proteinPerKg * userProfile.weight))g au total)
        - Lipides: \(Int(dailyFat))g (\(Int(fatPerKg * userProfile.weight))g au total)
        - Glucides: \(Int(dailyCarbs))g
        
        ALERTE CRITIQUE SUR LES CALORIES : Je constate que tu ignores systématiquement les besoins caloriques indiqués. Les valeurs suivantes sont ABSOLUMENT OBLIGATOIRES ! J
        - Petit-déjeuner: EXCATEMENT \(Int(breakfastCalories)) calories
        - Déjeuner: EXCATEMENT \(Int(lunchCalories)) calories
        - Dîner: EXCATEMENT \(Int(dinnerCalories)) calories
        - Collation: EXCATEMENT \(Int(snackCalories)) calories
        
        Les calories indiquées pour les repas ci-dessus NE SONT PAS des suggestions mais des OBLIGATIONS.
        La somme des calories des ingrédients de chaque repas DOIT correspondre à ces valeurs à 5% près.       
        Les repas doivent être nutritionnellement complets et sastisfaisants. Les portions doivent être adaptées au profil detaillé plus haut.
        """
    }
}


struct MealPlan: Codable, Identifiable {
    let id: UUID
    var weekNumber: Int
    var year: Int
    var plannedMeals: [PlannedMeal]
    
    var sortedMeals: [PlannedMeal] {
        plannedMeals.sorted { $0.meal.date < $1.meal.date }
    }
    
    var groupedByDate: [Date: [PlannedMeal]] {
        Dictionary(grouping: plannedMeals) { meal in
            Calendar.current.startOfDay(for: meal.meal.date)
        }
    }
    
    init(id: UUID = UUID(), weekNumber: Int, year: Int, plannedMeals: [PlannedMeal] = []) {
        self.id = id
        self.weekNumber = weekNumber
        self.year = year
        self.plannedMeals = plannedMeals
    }
}

struct PlannedMeal: Codable, Identifiable {
    let id: UUID
    var meal: Meal
    var servings: Int
    var guests: Int
    
    var totalServings: Int {
        servings + guests
    }
    
    init(id: UUID = UUID(), meal: Meal, servings: Int, guests: Int = 0) {
        self.id = id
        self.meal = meal
        self.servings = servings
        self.guests = guests
    }
}


