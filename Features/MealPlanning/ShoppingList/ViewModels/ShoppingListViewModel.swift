//
//  ShoppingListViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

// ShoppingListViewModel.swift
class ShoppingListViewModel: ObservableObject {
    @Published var items: [ShoppingItem] = []
    @Published var showingAddItem = false
    
    func toggleItem(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isChecked.toggle()
            // Sauvegarder les changements si nécessaire
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        // Sauvegarder les changements si nécessaire
    }
}

struct ShoppingItem: Identifiable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var isChecked: Bool
}
