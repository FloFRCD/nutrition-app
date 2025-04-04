//
//  shoppingItems.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/03/2025.
//

import Foundation

struct ShoppingItem: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    let name: String
    var quantity: Double
    var unit: String
    var category: IngredientCategory
    var isChecked: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
        hasher.combine(unit.lowercased())
    }

    static func == (lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        return lhs.name.lowercased() == rhs.name.lowercased() && lhs.unit.lowercased() == rhs.unit.lowercased()
    }
}
