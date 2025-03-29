//
//  NutritionCalculator.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

// Structure pour stocker tous les besoins nutritionnels calculés
struct NutritionalNeeds: Codable {
    let totalCalories: Double
    let bmr: Double
    let tdee: Double
    let maintenanceCalories: Double
    
    // Macronutriments en grammes
    let proteins: Double
    let fats: Double
    let carbs: Double
    let fiber: Double
    
    // Répartition par repas
    let breakfastCalories: Double
    let lunchCalories: Double
    let dinnerCalories: Double
    let snackCalories: Double
    
    // Métadonnées pour informations supplémentaires
    let proteinPerKg: Double
    let fatPerKg: Double
}

// Classe singleton pour les calculs nutritionnels
class NutritionCalculator {
    static let shared = NutritionCalculator()
    
    private init() {}
    
    // Méthode principale pour calculer tous les besoins nutritionnels
    func calculateNeeds(for userProfile: UserProfile) -> NutritionalNeeds {
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
        
        // Besoins caloriques totaux (TDEE) = maintenanceCalories
        let tdee = bmr * activityFactor
        let maintenanceCalories = tdee
        
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
        
        // Calcul des fibres (généralement 14g pour chaque 1000 calories)
        let dailyFiber = (targetCalories / 1000) * 14
        
        // Répartition par repas
        let breakfastCalories = targetCalories * 0.25
        let lunchCalories = targetCalories * 0.35
        let dinnerCalories = targetCalories * 0.3
        let snackCalories = targetCalories * 0.1
        
        return NutritionalNeeds(
               totalCalories: targetCalories,
               bmr: bmr,
               tdee: tdee,
               maintenanceCalories: maintenanceCalories,
               proteins: dailyProtein,
               fats: dailyFat,
               carbs: dailyCarbs,
               fiber: dailyFiber,
               breakfastCalories: breakfastCalories,
               lunchCalories: lunchCalories,
               dinnerCalories: dinnerCalories,
               snackCalories: snackCalories,
               proteinPerKg: proteinPerKg,
               fatPerKg: fatPerKg
           )
    }
    
    // Méthode pour générer un texte formaté pour les prompts AI
    func generateNutritionalPromptText(for userProfile: UserProfile) -> String {
        let needs = calculateNeeds(for: userProfile)
        
        return """
        Informations nutritionnelles personnalisées:
        - Métabolisme basal: \(Int(needs.bmr)) calories/jour
        - Besoins caloriques totaux: \(Int(needs.tdee)) calories/jour
        - Objectif calorique quotidien: \(Int(needs.totalCalories)) calories/jour selon l'objectif de \(userProfile.fitnessGoal.rawValue)
        
        Besoins quotidiens en macronutriments:
        - Protéines: \(Int(needs.proteins))g (\(Int(needs.proteinPerKg * userProfile.weight))g au total)
        - Lipides: \(Int(needs.fats))g (\(Int(needs.fatPerKg * userProfile.weight))g au total)
        - Glucides: \(Int(needs.carbs))g
        - Fibres: \(Int(needs.fiber))g
        
        ALERTE CRITIQUE SUR LES CALORIES : Je constate que tu ignores systématiquement les besoins caloriques indiqués. Les valeurs suivantes sont ABSOLUMENT OBLIGATOIRES !
        - Petit-déjeuner: EXACTEMENT \(Int(needs.breakfastCalories)) calories
        - Déjeuner: EXACTEMENT \(Int(needs.lunchCalories)) calories
        - Dîner: EXACTEMENT \(Int(needs.dinnerCalories)) calories
        - Collation: EXACTEMENT \(Int(needs.snackCalories)) calories
        
        Les calories indiquées pour les repas ci-dessus NE SONT PAS des suggestions mais des OBLIGATIONS.
        La somme des calories des ingrédients de chaque repas DOIT correspondre à ces valeurs à 5% près.       
        Les repas doivent être nutritionnellement complets et sastisfaisants. Les portions doivent être adaptées au profil detaillé plus haut.
        """
    }
}

