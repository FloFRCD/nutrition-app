//
//  NutritionCalculator.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

// NutritionCalculator.swift
class NutritionCalculator {
    static let shared = NutritionCalculator()
    private init() {}
    
    struct NutritionNeeds {
        let maintenanceCalories: Int
        let targetCalories: Int
        let proteins: Int      // en grammes
        let carbs: Int        // en grammes
        let fats: Int         // en grammes
    }
    
    func calculateNeeds(for profile: UserProfile) -> NutritionNeeds {
        // 1. Calcul du BMR (Basal Metabolic Rate) avec l'équation de Mifflin-St Jeor
        let bmr: Double
        switch profile.gender {
        case .male:
            bmr = 10 * profile.currentWeight + 6.25 * profile.height - 5 * Double(profile.age) + 5
        case .female:
            bmr = 10 * profile.currentWeight + 6.25 * profile.height - 5 * Double(profile.age) - 161
        case .other:
            // Moyenne des deux formules
            let maleBmr = 10 * profile.currentWeight + 6.25 * profile.height - 5 * Double(profile.age) + 5
            let femaleBmr = 10 * profile.currentWeight + 6.25 * profile.height - 5 * Double(profile.age) - 161
            bmr = (maleBmr + femaleBmr) / 2
        }
        
        // 2. Facteur d'activité
        let activityFactor: Double
        switch profile.activityLevel {
        case .sedentary: activityFactor = 1.2
        case .lightlyActive: activityFactor = 1.375
        case .moderatelyActive: activityFactor = 1.55
        case .veryActive: activityFactor = 1.725
        case .extraActive: activityFactor = 1.9
        }
        
        // 3. Calories de maintenance
        let maintenanceCalories = Int(bmr * activityFactor)
        
        // 4. Calories cibles basées sur l'objectif
        let targetCalories: Int
            switch profile.fitnessGoal {
            case .weightGain:
                // Prise de masse : surplus de 10%
                targetCalories = Int(Double(maintenanceCalories) * 1.1)
            case .weightLoss:
                // Perte de poids : déficit de 20%
                targetCalories = Int(Double(maintenanceCalories) * 0.8)
            case .maintenance:
                targetCalories = maintenanceCalories
            }
        
        // 5. Répartition des macronutriments
        let proteins: Int
            let fats: Int
            let carbs: Int
            
            switch profile.fitnessGoal {
            case .weightGain:
                // Prise de masse
                proteins = Int(2.2 * profile.currentWeight) // 2.2g/kg
                fats = Int(0.8 * profile.currentWeight)    // 0.8g/kg
                
            case .weightLoss:
                // Perte de poids
                proteins = Int(2.4 * profile.currentWeight) // 2.4g/kg pour préserver la masse
                fats = Int(0.6 * profile.currentWeight)    // 0.6g/kg
                
            case .maintenance:
                // Maintien
                proteins = Int(1.8 * profile.currentWeight)
                fats = Int(0.7 * profile.currentWeight)
            }
        
        // Le reste en glucides
        let proteinCalories = proteins * 4
        let fatCalories = fats * 9
        carbs = (targetCalories - proteinCalories - fatCalories) / 4
        
        return NutritionNeeds(
            maintenanceCalories: maintenanceCalories,
            targetCalories: targetCalories,
            proteins: proteins,
            carbs: carbs,
            fats: fats
        )
    }
} 
