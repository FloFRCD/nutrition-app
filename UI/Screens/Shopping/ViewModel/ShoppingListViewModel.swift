//
//  ShoppingListViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/03/2025.
//

import Foundation
class ShoppingListViewModel: ObservableObject {
    @Published var shoppingItems: [IngredientCategory: [ShoppingItem]] = [:]
    
    init() {
        // Initialiser chaque catégorie avec un tableau vide
        for category in IngredientCategory.allCases {
            shoppingItems[category] = []
        }
    }
    
    // Générer la liste de courses à partir des recettes sélectionnées
    func generateShoppingList(from recipes: [DetailedRecipe]) {
        // Réinitialiser la liste
        for category in IngredientCategory.allCases {
            shoppingItems[category] = []
        }
        
        // Temporaire: collecter tous les ingrédients sans fusion
        var allItems: [ShoppingItem] = []
        
        // Extraire tous les ingrédients de toutes les recettes
        for recipe in recipes {
            for ingredient in recipe.ingredients {
                let category = ingredient.name.ingredientCategory
                let item = ShoppingItem(
                    name: ingredient.name,
                    quantity: ingredient.quantity,
                    unit: ingredient.unit,
                    category: category
                )
                allItems.append(item)
            }
        }
        
        // Fusionner les ingrédients similaires
        let groupedItems = Dictionary(grouping: allItems) { item in
            return "\(item.name.lowercased())-\(item.unit.lowercased())"
        }
        
        // Pour chaque groupe, additionner les quantités
        for (_, items) in groupedItems {
            if let firstItem = items.first {
                var totalQuantity = items.reduce(0) { $0 + $1.quantity }
                
                // Arrondir à 1 décimale si nécessaire
                if totalQuantity.truncatingRemainder(dividingBy: 1) == 0 {
                    totalQuantity = totalQuantity.rounded()
                } else {
                    totalQuantity = (totalQuantity * 10).rounded() / 10
                }
                
                let mergedItem = ShoppingItem(
                    name: firstItem.name,
                    quantity: totalQuantity,
                    unit: firstItem.unit,
                    category: firstItem.category
                )
                
                // Ajouter à la catégorie appropriée
                shoppingItems[firstItem.category, default: []].append(mergedItem)
            }
        }
        
        // Trier les ingrédients par nom dans chaque catégorie
        for category in IngredientCategory.allCases {
            shoppingItems[category]?.sort { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
    
    // Marquer un élément comme coché ou non coché
    func toggleItemCheck(item: ShoppingItem) {
        if let index = shoppingItems[item.category]?.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[item.category]?[index].isChecked.toggle()
        }
    }
    
    // Vérifier si la liste est vide
    var isEmpty: Bool {
        return shoppingItems.values.allSatisfy { $0.isEmpty }
    }
}



