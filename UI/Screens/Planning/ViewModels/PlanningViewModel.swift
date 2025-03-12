//
//  PlanningViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/02/2025.
//

import Foundation
import SwiftUI

@MainActor
class PlanningViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var localDataManager: LocalDataManager?
    private var aiService: AIService?
    
    func setDependencies(localDataManager: LocalDataManager, aiService: AIService) {
        self.localDataManager = localDataManager
        self.aiService = aiService
    }
    
    private func standardizeQuantity(amount: Double, unit: String) -> (quantity: Double, unit: ServingUnit) {
        let standardizedUnit = unit.lowercased()
        
        switch standardizedUnit {
        case "g", "grammes", "gramme":
            return (amount, .gram)
            
        case "ml", "millilitres", "millilitre":
            return (amount, .milliliter)
            
        case "càs", "cuillère à soupe", "cuillères à soupe":
            // 1 càs ≈ 15g/ml
            return (amount * 15, .gram)
            
        case "càc", "cuillère à café", "cuillères à café":
            // 1 càc ≈ 5g/ml
            return (amount * 5, .gram)
            
        case "pincée", "pincées":
            // 1 pincée ≈ 1g
            return (amount, .gram)
            
        case "pièce", "piece", "unité", "unite":
            return (amount, .piece)
            
        default:
            print("Unité non reconnue, utilisation de pièce:", unit)
            return (amount, .piece)
        }
    }
    
    func generateWeeklyPlan(with preferences: MealPreferences) async {
        let prompt = preferences.aiPromptFormat
        guard let localDataManager = localDataManager,
              let aiService = aiService else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Limiter à 3 jours maximum pour éviter les dépassements de tokens
            let safePreferences = limitPreferencesToMaxDays(preferences)
            
            // Ajout d'un message système explicite dans le service API
            let jsonString = try await aiService.generateMealPlan(
                prompt: safePreferences.aiPromptFormat,
                systemPrompt: "IMPORTANT: Génère EXACTEMENT \(safePreferences.numberOfDays) jour(s) avec UNIQUEMENT les types de repas spécifiés. Ne génère pas de repas supplémentaires."
            )
            
            print("\n=== DÉBUT DU DEBUG ===")
            print(prompt)
            print("JSON reçu:", jsonString.prefix(100))
            
            // Décodage direct du plan de repas
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw OpenAIError.decodingError("Impossible de convertir en données")
            }
            
            // Tentative de décodage, avec récupération en cas d'erreur
            let mealPlan: AIMealPlanResponse
            do {
                mealPlan = try JSONDecoder().decode(AIMealPlanResponse.self, from: jsonData)
            } catch {
                // Si le JSON est tronqué, tentez de récupérer la partie valide
                print("Erreur décodage initial:", error)
                if let repairedJson = repairTruncatedJSON(jsonString) {
                    mealPlan = try JSONDecoder().decode(AIMealPlanResponse.self, from: repairedJson.data(using: .utf8)!)
                } else {
                    throw error
                }
            }
            
            // Limiter aux jours demandés (au cas où l'API en générerait trop)
            let limitedDays = Array(mealPlan.days.prefix(safePreferences.numberOfDays))
            print("Plan décodé, nombre de jours (après limitation):", limitedDays.count)
            
            var generatedMeals: [Meal] = []
            
            // Récupérer les besoins nutritionnels de l'utilisateur si disponibles
            let userProfile: UserProfile? = preferences.userProfile
            var targetCaloriesByMealType: [MealType: Double]? = nil
            
            if let profile = userProfile {
                let nutritionNeeds = NutritionCalculator.shared.calculateNeeds(for: profile)
                let targetCalories = Double(nutritionNeeds.targetCalories)
                
                // Définir les calories cibles par type de repas
                targetCaloriesByMealType = [
                    .breakfast: targetCalories * 0.20,
                    .lunch: targetCalories * 0.27,
                    .dinner: targetCalories * 0.25,
                    .snack: targetCalories * 0.10
                ]
            }
            
            // Conversion en repas
            for day in limitedDays {
                print("\nTraitement du jour:", day.date)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let date = dateFormatter.date(from: day.date) else {
                    print("❌ Date invalide:", day.date)
                    continue
                }
                
                for aiMeal in day.meals {
                    print("Traitement du repas:", aiMeal.name)
                    
                    let foods = aiMeal.ingredients.map { ingredient -> Food in
                        print("Ingrédient:", ingredient.name, ingredient.quantity, ingredient.unit)
                        
                        let standardized = standardizeQuantity(amount: ingredient.quantity, unit: ingredient.unit)
                        
                        return Food(
                            id: UUID(),
                            name: ingredient.name,
                            calories: ingredient.calories,
                            proteins: ingredient.proteines,
                            carbs: ingredient.glucides,
                            fats: ingredient.lipides,
                            servingSize: standardized.quantity,
                            servingUnit: standardized.unit
                        )
                    }
                    
                    let meal = Meal(
                        name: aiMeal.name,
                        date: date,
                        foods: foods,
                        type: determineMealType(from: aiMeal.type)
                    )
                    
                    // Ajuster les portions si nécessaire
                    if let targetCaloriesByType = targetCaloriesByMealType,
                       let targetCalories = targetCaloriesByType[meal.type] {
                        
                        let adjustedMeal = adjustMealPortions(meal: meal, targetCalories: targetCalories)
                        generatedMeals.append(adjustedMeal)
                        print("✅ Repas ajusté et ajouté:", adjustedMeal.name, "- Calories:", adjustedMeal.totalCalories)
                    } else {
                        generatedMeals.append(meal)
                        print("✅ Repas ajouté (sans ajustement):", meal.name)
                    }
                }
            }
            
            print("\n=== FIN DU PARSING ===")
            print("Nombre total de repas générés:", generatedMeals.count)
            
            // Sauvegarde et mise à jour de l'interface
            try await localDataManager.save(generatedMeals, forKey: "meals_\(getCurrentWeekKey())")
            self.meals = generatedMeals
            
        } catch {
            print("❌ Erreur lors de la génération:", error)
            self.error = error
        }
    }

    // Fonction d'ajustement des portions
    private func adjustMealPortions(meal: Meal, targetCalories: Double) -> Meal {
        // Calculer les calories actuelles
        let currentCalories = Double(meal.totalCalories)
        
        // Pour éviter la division par zéro
        guard currentCalories > 0 else { return meal }
        
        print("Ajustement du repas \(meal.name) - Avant: \(Int(currentCalories)) calories, Cible: \(Int(targetCalories)) calories")
        
        // Si les calories actuelles sont significativement différentes de la cible
        if abs(currentCalories - targetCalories) / targetCalories > 0.10 {
            // Calculer le facteur d'ajustement
            let adjustmentFactor = targetCalories / currentCalories
            print("Facteur d'ajustement: \(String(format: "%.2f", adjustmentFactor))")
            
            var adjustedMeal = meal
            var adjustedFoods: [Food] = []
            
            for food in meal.foods {
                // Créer une nouvelle instance avec les portions ajustées
                let adjustedFood = Food(
                    id: food.id,
                    name: food.name,
                    calories: Int(Double(food.calories) * adjustmentFactor),
                    proteins: food.proteins * adjustmentFactor,
                    carbs: food.carbs * adjustmentFactor,
                    fats: food.fats * adjustmentFactor,
                    servingSize: food.servingSize * adjustmentFactor,
                    servingUnit: food.servingUnit,
                    image: food.image
                )
                
                adjustedFoods.append(adjustedFood)
            }
            
            adjustedMeal.foods = adjustedFoods
            print("Après ajustement: \(adjustedMeal.totalCalories) calories")
            return adjustedMeal
        }
        
        // Si les calories sont déjà proches de la cible, on ne change rien
        print("Pas d'ajustement nécessaire, écart < 10%")
        return meal
    }
    
    private func validateResponse(_ response: AIMealPlanResponse, preferences: MealPreferences) -> Bool {
        // 1. Vérifier le nombre de jours
        guard response.days.count == preferences.numberOfDays else {
            print("⚠️ Nombre de jours incorrect: attendu \(preferences.numberOfDays), reçu \(response.days.count)")
            return false
        }
        
        // 2. Vérifier les types de repas pour chaque jour
        let expectedMealTypesSet = Set(preferences.mealTypes.map { $0.rawValue })
        
        for (index, day) in response.days.enumerated() {
            let responseMealTypes = day.meals.map { $0.type }
            let responseTypesSet = Set(responseMealTypes)
            
            // Vérifier qu'il n'y a pas de types de repas non demandés
            for type in responseTypesSet {
                if !expectedMealTypesSet.contains(type) {
                    print("⚠️ Jour \(index + 1): Type de repas non demandé reçu: \(type)")
                    return false
                }
            }
            
            // Vérifier que tous les types demandés sont présents
            for type in expectedMealTypesSet {
                if !responseTypesSet.contains(type) {
                    print("⚠️ Jour \(index + 1): Type de repas demandé manquant: \(type)")
                    return false
                }
            }
            
            // Vérifier qu'il n'y a pas de doublons de types de repas
            if responseMealTypes.count != Set(responseMealTypes).count {
                print("⚠️ Jour \(index + 1): Types de repas en double détectés")
                return false
            }
        }
        
        // 3. Vérifier les ingrédients bannis
        for (dayIndex, day) in response.days.enumerated() {
            for (mealIndex, meal) in day.meals.enumerated() {
                for ingredient in meal.ingredients {
                    for banned in preferences.bannedIngredients {
                        if !banned.isEmpty && ingredient.name.lowercased().contains(banned.lowercased()) {
                            print("⚠️ Jour \(dayIndex + 1), Repas \(mealIndex + 1): Ingrédient banni trouvé: \(ingredient.name) contient \(banned)")
                            return false
                        }
                    }
                }
            }
        }
        
        // 4. Vérifier les besoins caloriques si le profil utilisateur est disponible
            let userProfile = preferences.userProfile
            let nutritionNeeds = NutritionCalculator.shared.calculateNeeds(for: userProfile)
            let targetCalories = nutritionNeeds.targetCalories
            
            // Tolérance de 20% pour les calories
            let tolerance = 0.20
            
            // Répartition calorique attendue par type de repas
            let expectedCalories: [String: Double] = [
                MealType.breakfast.rawValue: targetCalories * 0.25,
                MealType.lunch.rawValue: targetCalories * 0.35,
                MealType.dinner.rawValue: targetCalories * 0.30,
                MealType.snack.rawValue: targetCalories * 0.10
            ]
            
            for (dayIndex, day) in response.days.enumerated() {
                var dailyCalories = 0.0
                
                for (mealIndex, meal) in day.meals.enumerated() {
                    // Calculer les calories totales du repas
                    let mealCaloriesFromIngredients = meal.ingredients.reduce(0) { $0 + ($1.calories ?? 0) }
                    
                    // Si les calories sont disponibles dans le repas lui-même
                    let mealCalories = mealCaloriesFromIngredients
                    dailyCalories += Double(mealCalories)
                    
                    // Vérifier si les calories du repas correspondent à l'attente pour ce type
                    if let expectedForType = expectedCalories[meal.type] {
                        let minAcceptable = expectedForType * (1 - tolerance)
                        let maxAcceptable = expectedForType * (1 + tolerance)
                        
                        if Double(mealCalories) < minAcceptable || Double(mealCalories) > maxAcceptable {
                            print("⚠️ Jour \(dayIndex + 1), \(meal.type): Calories incorrectes - attendu ~\(Int(expectedForType)), reçu \(mealCalories)")
                            // On continue malgré cette erreur car les calories sont souvent mal calculées par l'API
                            // return false
                        }
                    }
                }
                
                // Vérifier les calories totales journalières
                let minDailyAcceptable = Double(targetCalories) * (1 - tolerance)
                let maxDailyAcceptable = Double(targetCalories) * (1 + tolerance)
                
                if dailyCalories < minDailyAcceptable || dailyCalories > maxDailyAcceptable {
                    print("⚠️ Jour \(dayIndex + 1): Calories journalières incorrectes - attendu ~\(targetCalories), reçu \(Int(dailyCalories))")
                    // On continue malgré cette erreur
                    // return false
                }
            }
        
        // 5. Vérifier que tous les repas ont au moins un ingrédient
        for (dayIndex, day) in response.days.enumerated() {
            for (mealIndex, meal) in day.meals.enumerated() {
                if meal.ingredients.isEmpty {
                    print("⚠️ Jour \(dayIndex + 1), \(meal.type): Aucun ingrédient trouvé")
                    return false
                }
            }
        }
        
        return true
    }
    private func limitPreferencesToMaxDays(_ preferences: MealPreferences) -> MealPreferences {
        // Crée une copie des préférences avec le nombre de jours limité à 3
        var safePreferences = preferences
        safePreferences.numberOfDays = min(preferences.numberOfDays, 3)
        return safePreferences
    }

    private func repairTruncatedJSON(_ jsonString: String) -> String? {
        // Fonction simplifiée pour réparer un JSON tronqué
        // Cherche le dernier jour complet et ajoute les accolades/crochets manquants
        // Cette implémentation est basique, vous pourriez l'améliorer avec une analyse plus sophistiquée
        
        if let lastCompleteDay = jsonString.range(of: "\"date\":") {
            let beforeLastDay = String(jsonString[..<lastCompleteDay.lowerBound])
            if let lastCompleteDayEnd = beforeLastDay.lastIndex(of: "}") {
                let validPart = String(beforeLastDay[..<lastCompleteDayEnd])
                return validPart + "}}]}"
            }
        }
        return nil
    }

    private func determineMealType(from type: String) -> MealType {
        switch type {
        case "Petit-déjeuner":
            return .breakfast
        case "Déjeuner":
            return .lunch
        case "Dîner":
            return .dinner
        case "Collation":
            return .snack
        default:
            print("Type de repas non reconnu:", type)
            return .snack // Valeur par défaut
        }
    }
    
    private func getCurrentWeekKey() -> String {
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        return "\(year)_week\(week)"
    }
}
