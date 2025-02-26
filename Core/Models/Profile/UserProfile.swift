//
//  UserProfile.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation

// MARK: - User Profile
struct UserProfile: Codable {
    let id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var height: Double // en cm
    var weight: Double // en kg
    var bodyFatPercentage: Double? // en %
    var fitnessGoal: FitnessGoal
    var activityLevel: ActivityLevel
    var dietaryRestrictions: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        gender: Gender,
        height: Double,
        weight: Double,
        bodyFatPercentage: Double? = nil,
        fitnessGoal: FitnessGoal,
        activityLevel: ActivityLevel,
        dietaryRestrictions: [String] = []
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.fitnessGoal = fitnessGoal
        self.activityLevel = activityLevel
        self.dietaryRestrictions = dietaryRestrictions
    }
    
    // Calcul de l'IMC
    var bmi: Double {
        return weight / ((height / 100) * (height / 100))
    }
}

// MARK: - Gender
enum Gender: String, Codable, CaseIterable {
    case male = "Homme"
    case female = "Femme"
    case other = "Autre"
}

// MARK: - Fitness Goal
enum FitnessGoal: String, Codable, CaseIterable {
    case loseWeight = "Perte de poids"
    case maintainWeight = "Maintien du poids"
    case gainMuscle = "Gain musculaire"
    case improveHealth = "Améliorer la santé"
    
    var description: String {
        return self.rawValue
    }
}

// MARK: - Activity Level
enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sédentaire"
    case lightlyActive = "Légèrement actif"
    case moderatelyActive = "Modérément actif"
    case veryActive = "Très actif"
    case extraActive = "Extrêmement actif"
    
    var factor: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }
    
    var description: String {
        return self.rawValue
    }
}

enum DietaryPreference: String, Codable, CaseIterable {
    case none = "Aucune"
    case vegetarian = "Végétarien"
    case vegan = "Végétalien"
    case glutenFree = "Sans gluten"
    case dairyFree = "Sans lactose"
}
