//
//  FoodScan.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

struct FoodScan: Identifiable, Codable {
    let id: UUID
    let food: Food
    let date: Date
    let isChecked: Bool
    
    init(id: UUID = UUID(), food: Food, date: Date = Date(), isChecked: Bool = false) {
        self.id = id
        self.food = food
        self.date = date
        self.isChecked = isChecked
    }
}
