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
    var date: Date
    var foods: [Food]
    var type: MealType
    
    var totalCalories: Int {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    init(id: UUID = UUID(), name: String, date: Date, foods: [Food] = [], type: MealType) {
        self.id = id
        self.name = name
        self.date = date
        self.foods = foods
        self.type = type
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Petit-déjeuner"
    case lunch = "Déjeuner"
    case dinner = "Dîner"
    case snack = "Collation"
}
