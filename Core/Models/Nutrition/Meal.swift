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
enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "Végétarien"
    case vegan = "Végétalien"
    case glutenFree = "Sans gluten"
    case lactoseFree = "Sans lactose"
}

struct MealPreferences: Codable {
    var bannedIngredients: [String]
    var preferredIngredients: [String]
    var defaultServings: Int
    var dietaryRestrictions: [DietaryRestriction]
    var numberOfDays: Int
    var mealTypes: [MealType]
    var userProfile: UserProfile
    
    var aiPromptFormat: String {
        
        let nutritionalInfo = calculateNutritionalNeeds(userProfile: userProfile)
        let heightInMeters = userProfile.height / 100
        let numberOfDays = numberOfDays

        return """
        Tu es un chef cuisinier renommé spécialisé en nutrition. Ta mission est de proposer des titres de repas personnalisés, créatifs et savoureux.
        
        PROFIL UTILISATEUR:
        - Age: \(userProfile.age) ans
        - Sexe: \(userProfile.gender.rawValue)
        - Poids actuel: \(userProfile.weight) kg
        - Taille: \(userProfile.height) cm
        - Objectif: \(userProfile.fitnessGoal.rawValue)
        - Niveau d'activité: \(userProfile.activityLevel.rawValue)
        \(userProfile.bodyFatPercentage != nil ? "- Pourcentage de masse graisseuse: \(userProfile.bodyFatPercentage!)%" : "")

        CONTRAINTES DU PLAN DE REPAS:
        - Types de repas: \(mealTypes.map { $0.rawValue }.joined(separator: ", "))
        - Restrictions alimentaires: \(dietaryRestrictions.map { $0.rawValue }.joined(separator: ", "))
        - Ingrédients à éviter: \(bannedIngredients.joined(separator: ", "))
        - Ingrédients préférés: \(preferredIngredients.joined(separator: ", "))
        
        CONSIGNES:
        Propose 10 idées de repas variées et créatives qui correspondent au profil nutritionnel et aux préférences de l'utilisateur.
        Chaque proposition doit contenir uniquement:
        1. Le nom du repas (max 10 mots)
        2. Une brève description (max 15 mots)
        3. Le type de repas
        
        IMPORTANT: Réponds UNIQUEMENT avec un JSON au format suivant:
        {
            "meal_suggestions": [
                {
                    "name": "Nom du repas",
                    "description": "Brève description",
                    "type": "Type de repas"
                }
            ]
        }
        
        Tu ne retournes que le format JSON. Aucun autre texte.
        Les types de repas: "Petit-déjeuner", "Déjeuner", "Dîner", "Collation"
        """
    }
    
    init(bannedIngredients: [String] = [],
         preferredIngredients: [String] = [],
         defaultServings: Int = 1,
         dietaryRestrictions: [DietaryRestriction] = [],
         numberOfDays: Int = 7,
         mealTypes: [MealType] = [],
         userProfile: UserProfile) {
        
        self.bannedIngredients = bannedIngredients
        self.preferredIngredients = preferredIngredients
        self.defaultServings = defaultServings
        self.dietaryRestrictions = dietaryRestrictions
        self.numberOfDays = numberOfDays
        self.mealTypes = mealTypes
        self.userProfile = userProfile
        
        if !userProfile.dietaryRestrictions.isEmpty {
            var updatedRestrictions = self.dietaryRestrictions
            
            for restriction in userProfile.dietaryRestrictions {
                if let dietaryrestrictions = DietaryRestriction(rawValue: restriction) {
                    if !updatedRestrictions.contains(dietaryrestrictions) {
                        updatedRestrictions.append(dietaryrestrictions)
                    }
                } else {
                    if !self.bannedIngredients.contains(restriction) {
                        self.bannedIngredients.append(restriction)
                    }
                }
            }
            
            self.dietaryRestrictions = updatedRestrictions
            
        }
    }
    
}
extension MealPreferences {
    func printDebugPrompt() {
        print("------- DEBUT DU PROMPT ---------")
        print(aiPromptFormat)
        print("------- FIN DU PROMPT ---------")
    }

    func validateMeal(_ meal: Meal) -> Bool {
        // Vérifier que les ingrédients bannis ne sont pas présents
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
