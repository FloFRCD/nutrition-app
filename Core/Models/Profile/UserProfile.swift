//
//  UserProfile.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation


struct UserProfile: Codable {
    var name: String
    var age: Int
    var gender: Gender
    var height: Double
    var currentWeight: Double
    var targetWeight: Double?
    var activityLevel: ActivityLevel
    var dietaryPreferences: [DietaryPreference]
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
