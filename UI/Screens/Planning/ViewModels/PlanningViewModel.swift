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
    guard let localDataManager = localDataManager,
              let aiService = aiService else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Obtention du plan JSON directement
            let jsonString = try await aiService.generateMealPlan(prompt: preferences.aiPromptFormat)
            print("\n=== DÉBUT DU DEBUG ===")
            print("JSON reçu:", jsonString.prefix(100))
            
            // Décodage direct du plan de repas
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw OpenAIError.decodingError("Impossible de convertir en données")
            }
            
            let mealPlan = try JSONDecoder().decode(AIMealPlanResponse.self, from: jsonData)
            print("Plan décodé, nombre de jours:", mealPlan.days.count)
            
            var generatedMeals: [Meal] = []
            
            // Conversion en repas
            for day in mealPlan.days {
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
                            calories: aiMeal.calories / aiMeal.ingredients.count,
                            proteins: 0,
                            carbs: 0,
                            fats: 0,
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
                    
                    generatedMeals.append(meal)
                    print("✅ Repas ajouté:", meal.name)
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
    private func determineMealType(from type: String) -> MealType {
        switch type {
        case "Déjeuner":
            return .lunch
        case "Dîner":
            return .dinner
        default:
            print("Type de repas non reconnu:", type)
            return .snack
        }
    }
    
    private func getCurrentWeekKey() -> String {
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        return "\(year)_week\(week)"
    }
}
