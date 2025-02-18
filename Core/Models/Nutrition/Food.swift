//
//  Food.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

enum ServingUnit: String, Codable {
    case gram = "g"
    case milliliter = "ml"
    case piece = "pc"
}

struct Food: Identifiable, Codable {
    let id: UUID
    var name: String
    var calories: Int
    var proteins: Double
    var carbs: Double
    var fats: Double
    var servingSize: Double
    var servingUnit: ServingUnit
    var image: String?
}
