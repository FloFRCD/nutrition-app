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

    let proteins: Double
    let fats: Double
    let carbs: Double
    let fiber: Double

    let breakfastCalories: Double
    let lunchCalories: Double
    let dinnerCalories: Double
    let snackCalories: Double

    let proteinPerKg: Double
    let fatPerKg: Double
}

class NutritionCalculator {
    static let shared = NutritionCalculator()
    private init() {}

    private let caloriesPerGramProtein = 4.0
    private let caloriesPerGramFat = 9.0
    private let caloriesPerGramCarb = 4.0
    private let fiberPer1000Calories = 14.0
    private let minFatPerKg = 0.6

    func calculateNeeds(for userProfile: UserProfile) -> NutritionalNeeds {
        let isMale = userProfile.gender == .male
        let bmr = calculateBMR(weight: userProfile.weight, height: userProfile.height, age: userProfile.age, isMale: isMale)
        let tdee = bmr * activityFactor(for: userProfile.activityLevel)
        let maintenanceCalories = tdee

        var targetCalories = tdee
        var proteinPerKg = 1.6
        var fatPerKg = 1.0

        switch userProfile.fitnessGoal {
        case .loseWeight:
            targetCalories = tdee * 0.8
            proteinPerKg = 2.2
            fatPerKg = 0.8
        case .maintainWeight:
            proteinPerKg = 1.6
            fatPerKg = 1.0
        case .gainMuscle:
            targetCalories = tdee * 1.15
            proteinPerKg = 2.0
            fatPerKg = 1.0
        }

        fatPerKg = max(fatPerKg, minFatPerKg)

        let dailyProtein = userProfile.weight * proteinPerKg
        let dailyFat = userProfile.weight * fatPerKg
        let proteinCalories = dailyProtein * caloriesPerGramProtein
        let fatCalories = dailyFat * caloriesPerGramFat

        let carbCalories = max(0, targetCalories - proteinCalories - fatCalories)
        let dailyCarbs = carbCalories / caloriesPerGramCarb
        let dailyFiber = (targetCalories / 1000) * fiberPer1000Calories

        let (breakfast, lunch, dinner, snack) = mealDistribution(from: targetCalories)

        return NutritionalNeeds(
            totalCalories: targetCalories,
            bmr: bmr,
            tdee: tdee,
            maintenanceCalories: maintenanceCalories,
            proteins: dailyProtein,
            fats: dailyFat,
            carbs: dailyCarbs,
            fiber: dailyFiber,
            breakfastCalories: breakfast,
            lunchCalories: lunch,
            dinnerCalories: dinner,
            snackCalories: snack,
            proteinPerKg: proteinPerKg,
            fatPerKg: fatPerKg
        )
    }

    private func calculateBMR(weight: Double, height: Double, age: Int, isMale: Bool) -> Double {
        return 10 * weight + 6.25 * height - 5 * Double(age) + (isMale ? 5 : -161)
    }

    private func activityFactor(for level: ActivityLevel) -> Double {
        switch level {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }

    private func mealDistribution(from totalCalories: Double) -> (Double, Double, Double, Double) {
        return (
            totalCalories * 0.25, // breakfast
            totalCalories * 0.35, // lunch
            totalCalories * 0.30, // dinner
            totalCalories * 0.10  // snack
        )
    }

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


