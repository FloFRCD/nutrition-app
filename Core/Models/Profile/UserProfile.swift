//
//  UserProfile.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation


enum FitnessGoal: String, Codable, CaseIterable {
    case weightLoss = "Perte de poids"
    case weightGain = "Prise de masse"
    case maintenance = "Maintien musculaire"
}


struct UserProfile: Codable {
    var id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var height: Double
    var currentWeight: Double
    var bodyFatPercentage: Double?
    var fitnessGoal: FitnessGoal
    var activityLevel: ActivityLevel
    var dietaryPreferences: [DietaryPreference]
    
    init(
        id: UUID,
        name: String,
        age: Int,
        gender: Gender,
        height: Double,
        currentWeight: Double,
        bodyFatPercentage: Double,
        fitnessGoal: FitnessGoal,
        activityLevel: ActivityLevel,
        dietaryPreferences: [DietaryPreference]
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.height = height
        self.currentWeight = currentWeight
        self.bodyFatPercentage = bodyFatPercentage
        self.fitnessGoal = fitnessGoal
        self.activityLevel = activityLevel
        self.dietaryPreferences = dietaryPreferences
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Homme"
    case female = "Femme"
    case other = "Autre"
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sédentaire"
    case lightlyActive = "Légèrement actif"
    case moderatelyActive = "Modérément actif"
    case veryActive = "Très actif"
    case extraActive = "Extrêmement actif"
}

enum DietaryPreference: String, Codable, CaseIterable {
    case none = "Aucune"
    case vegetarian = "Végétarien"
    case vegan = "Végétalien"
    case glutenFree = "Sans gluten"
    case dairyFree = "Sans lactose"
}
