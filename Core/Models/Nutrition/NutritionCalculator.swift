//
//  NutritionCalculator.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

class NutritionCalculator {
    // Instance singleton pour faciliter l'accès
    static let shared = NutritionCalculator()
    
    // Structure pour les besoins nutritionnels quotidiens
    struct NutritionNeeds {
        let calories: Double
        let proteins: Double
        let carbohydrates: Double
        let fats: Double
        let fiber: Double
        let maintenanceCalories: Double
        let targetCalories: Double
        
        // Pour compatibilité avec votre code existant
        var carbs: Double { return carbohydrates }
    }
    
    // Calculer les besoins nutritionnels quotidiens en fonction du profil utilisateur
    func calculateNeeds(for userProfile: UserProfile) -> NutritionNeeds {
        // Calcul des besoins caloriques de base (BMR) avec la formule de Mifflin-St Jeor
        let bmr: Double
        
        if userProfile.gender == .male {
            bmr = 10 * userProfile.weight + 6.25 * userProfile.height - 5 * Double(userProfile.age) + 5
        } else {
            bmr = 10 * userProfile.weight + 6.25 * userProfile.height - 5 * Double(userProfile.age) - 161
        }
        
        // Ajuster selon le niveau d'activité
        let maintenanceCalories = bmr * userProfile.activityLevel.factor
        
        // Ajuster les calories selon l'objectif
        let targetCalories: Double
        
        switch userProfile.fitnessGoal {
        case .loseWeight:
            targetCalories = maintenanceCalories * 0.8 // Déficit de 20%
        case .maintainWeight:
            targetCalories = maintenanceCalories
        case .gainMuscle:
            targetCalories = maintenanceCalories * 1.1 // Surplus de 10%
        case .improveHealth:
            targetCalories = maintenanceCalories
        }
        
        // Calculer la répartition des macronutriments selon l'objectif
        var proteinPercentage: Double = 0.25
        var fatPercentage: Double = 0.3
        var carbPercentage: Double = 0.45
        
        switch userProfile.fitnessGoal {
        case .loseWeight:
            proteinPercentage = 0.3
            fatPercentage = 0.3
            carbPercentage = 0.4
        case .gainMuscle:
            proteinPercentage = 0.35
            fatPercentage = 0.25
            carbPercentage = 0.4
        case .improveHealth:
            proteinPercentage = 0.25
            fatPercentage = 0.3
            carbPercentage = 0.45
        case .maintainWeight:
            proteinPercentage = 0.25
            fatPercentage = 0.3
            carbPercentage = 0.45
        }
        
        // Calculer les grammes de chaque macronutriment
        // 1g de protéine = 4 calories, 1g de glucides = 4 calories, 1g de lipides = 9 calories
        let proteins = (targetCalories * proteinPercentage) / 4
        let carbs = (targetCalories * carbPercentage) / 4
        let fats = (targetCalories * fatPercentage) / 9
        
        // Calculer les besoins en fibres (généralement 14g par 1000 calories)
        let fiber = targetCalories / 1000 * 14
        
        return NutritionNeeds(
            calories: targetCalories,
            proteins: proteins,
            carbohydrates: carbs,
            fats: fats,
            fiber: fiber,
            maintenanceCalories: maintenanceCalories,
            targetCalories: targetCalories
        )
    }
}

// Extension pour ajouter des méthodes utilitaires
extension NutritionCalculator.NutritionNeeds {
    // Méthode pour vérifier si les besoins nutritionnels sont satisfaits par un repas
    func isSatisfiedBy(nutritionValues: NutritionValues) -> Bool {
        // Exemple simple: vérifie si les valeurs sont à au moins 20% des besoins quotidiens
        let caloriesSatisfied = nutritionValues.calories >= (calories * 0.2)
        let proteinsSatisfied = nutritionValues.proteins >= (proteins * 0.2)
        let carbsSatisfied = nutritionValues.carbohydrates >= (carbohydrates * 0.2)
        let fatsSatisfied = nutritionValues.fats >= (fats * 0.2)
        
        return caloriesSatisfied && proteinsSatisfied && carbsSatisfied && fatsSatisfied
    }
}

