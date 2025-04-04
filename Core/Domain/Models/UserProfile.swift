//
//  UserProfile.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation

// MARK: - User Profile
struct UserProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var height: Double // en cm
    var weight: Double // en kg
    var startingWeight: Double  // Poids initial au début du suivi
    var targetWeight: Double?   // Objectif de poids défini par l'utilisateur
    var bodyFatPercentage: Double? // en %
    var fitnessGoal: FitnessGoal
    var activityLevel: ActivityLevel
    var dietaryRestrictions: [String]
    var activityDetails: ActivityDetails?
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        gender: Gender,
        height: Double,
        weight: Double,
        startingWeight: Double? = nil,
        targetWeight: Double? = nil,
        bodyFatPercentage: Double? = nil,
        fitnessGoal: FitnessGoal,
        activityLevel: ActivityLevel,
        dietaryRestrictions: [String] = [],
        activityDetails: ActivityDetails?
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
        self.startingWeight = startingWeight ?? weight
        self.targetWeight = targetWeight
        self.bodyFatPercentage = bodyFatPercentage
        self.fitnessGoal = fitnessGoal
        self.activityLevel = activityLevel
        self.dietaryRestrictions = dietaryRestrictions
        self.activityDetails = activityDetails
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
