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
        // Calcul du BMR avec Mifflin-St Jeor (inchangé, cette formule est correcte)
        let bmr: Double
        
        if userProfile.gender == .male {
            bmr = 10 * userProfile.weight + 6.25 * userProfile.height - 5 * Double(userProfile.age) + 5
        } else {
            bmr = 10 * userProfile.weight + 6.25 * userProfile.height - 5 * Double(userProfile.age) - 161
        }
        
        // Facteurs d'activité plus précis
        var activityFactor: Double
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
        
        // Calcul plus précis des calories de maintenance
        let maintenanceCalories = bmr * activityFactor
        
        // Ajustement des calories selon l'objectif
        let targetCalories: Double
        switch userProfile.fitnessGoal {
        case .loseWeight:
            targetCalories = maintenanceCalories * 0.85 // Déficit de 15% (moins agressif)
        case .maintainWeight:
            targetCalories = maintenanceCalories // Pas de déficit pour maintien
        case .gainMuscle:
            targetCalories = maintenanceCalories * 1.1 // Surplus de 10%
        }
        
        // Ajustement des macronutriments selon l'objectif
        // Protéines: 1.6-2.2g/kg de poids corporel selon l'objectif
        let proteinPerKg: Double
        var fatPercentage: Double
        
        switch userProfile.fitnessGoal {
        case .loseWeight:
            proteinPerKg = 2.0 // Protéines plus élevées pour préserver la masse musculaire
            fatPercentage = 0.25
        case .maintainWeight:
            proteinPerKg = 1.6
            fatPercentage = 0.30
        case .gainMuscle:
            proteinPerKg = 1.8
            fatPercentage = 0.25
        }
        
        // Calcul des protéines en g basé sur le poids corporel
        let proteins = userProfile.weight * proteinPerKg
        
        // Calcul des lipides basé sur un pourcentage des calories totales
        let fats = (targetCalories * fatPercentage) / 9
        
        // Calcul des glucides pour compléter les calories
        let proteinCalories = proteins * 4
        let fatCalories = fats * 9
        let remainingCalories = targetCalories - proteinCalories - fatCalories
        let carbs = remainingCalories / 4
        
        // Calcul des fibres (25-30g par jour est la recommandation standard)
        let fiber = min(targetCalories / 1000 * 12, 30)
        
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

