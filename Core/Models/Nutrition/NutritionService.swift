//
//  NutritionService.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 26/02/2025.
//

import Foundation
import Combine

class NutritionService {
    static let shared = NutritionService()
    private let openFoodFactsService = OpenFoodFactsService()
    
    // MARK: - Recipe Analysis Methods
    
    /// Vérifie si une recette respecte les objectifs nutritionnels d'un profil utilisateur
    func isRecipeMatchingUserGoals(_ recipe: Recipe, userProfile: UserProfile) -> Bool {
        guard let nutrition = recipe.nutritionValues else {
            return false
        }
        
        let userNeeds = NutritionCalculator.shared.calculateNeeds(for: userProfile)
        
        // Vérifier si la recette correspond aux besoins (approximativement)
        switch userProfile.fitnessGoal {
        case .loseWeight:
            // Pour la perte de poids, vérifier que les calories sont modérées
            // et les protéines suffisantes
            return nutrition.calories < userNeeds.totalCalories / 3 &&
                   nutrition.proteins > userNeeds.proteins / 4
            
        case .maintainWeight:
            // Pour le maintien, vérifier un équilibre général
            return nutrition.calories < userNeeds.maintenanceCalories / 3 &&
            nutrition.calories > userNeeds.maintenanceCalories / 5
            
        case .gainMuscle:
            // Pour le gain musculaire, vérifier que les protéines sont élevées
            return nutrition.proteins > userNeeds.proteins / 3
        }
    }
    
    // MARK: - Nutrition Information Methods
    
    /// Analyse complète d'une recette en recherchant les informations nutritionnelles pour chaque ingrédient
    func analyzeRecipeNutrition(_ recipe: Recipe) async throws -> Recipe {
        var updatedRecipe = recipe
        
        // Calculer les valeurs nutritionnelles totales
        var totalCalories: Double = 0
        var totalProteins: Double = 0
        var totalCarbs: Double = 0
        var totalFats: Double = 0
        var totalFiber: Double = 0
        
        // Pour chaque ingrédient
        for ingredient in recipe.ingredients {
            if let gramsAmount = ingredient.quantityInGrams() {
                // Utiliser AIService pour obtenir les infos nutritionnelles
                // Noter que ceci est temporaire avant l'implémentation d'OpenFoodFacts
                let nutritionInfo = try await AIService.shared.analyzeNutrition(food: "\(gramsAmount)g de \(ingredient.name)")
                
                // Ajouter aux totaux
                totalCalories += nutritionInfo.calories
                totalProteins += nutritionInfo.proteins
                totalCarbs += nutritionInfo.carbs
                totalFats += nutritionInfo.fats
                
                // On utilise une valeur estimée pour les fibres (environ 10% des glucides)
                totalFiber += nutritionInfo.carbs * 0.1
            }
        }
        
        // Calculer par portion
        let caloriesPerServing = totalCalories / Double(recipe.servings)
        let proteinsPerServing = totalProteins / Double(recipe.servings)
        let carbsPerServing = totalCarbs / Double(recipe.servings)
        let fatsPerServing = totalFats / Double(recipe.servings)
        let fiberPerServing = totalFiber / Double(recipe.servings)
        
        // Créer l'objet NutritionValues
        let nutritionValues = NutritionValues(
            calories: caloriesPerServing,
            proteins: proteinsPerServing,
            carbohydrates: carbsPerServing,
            fats: fatsPerServing,
            fiber: fiberPerServing
        )
        
        // Mettre à jour la recette
        updatedRecipe.nutritionValues = nutritionValues
        
        return updatedRecipe
    }
    
    // MARK: - Future OpenFoodFacts Integration
    
    /// Cette méthode sera implémentée ultérieurement avec OpenFoodFacts
    func findIngredientInOpenFoodFacts(_ ingredientName: String) async throws -> String? {
        // Dans une future implémentation, cela recherchera l'ingrédient dans OpenFoodFacts
        // et retournera son ID
        return nil
    }
}
