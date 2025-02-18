//
//  Meal.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation


struct Meal: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: MealType
    var foods: [Food]
    var date: Date
    var image: String?
    var notes: String?
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Petit-déjeuner"
    case lunch = "Déjeuner"
    case dinner = "Dîner"
    case snack = "Collation"
}
