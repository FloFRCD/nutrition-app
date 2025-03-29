//
//  Goals.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct Goals: Codable {
    var dailyCalories: Int
    var proteinPercentage: Double
    var carbsPercentage: Double
    var fatsPercentage: Double
    var weeklyWorkouts: Int
    var waterIntake: Double
}
