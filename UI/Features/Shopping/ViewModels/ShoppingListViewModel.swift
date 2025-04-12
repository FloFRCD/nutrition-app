//
//  ShoppingListViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/03/2025.
//

import Foundation
import SwiftUI


class ShoppingListViewModel: ObservableObject {
    @Published var shoppingItems: [IngredientCategory: [ShoppingItem]] = [:]
    private var localDataManager: LocalDataManager?
    
    // Ajouter cette propriété à ShoppingListViewModel
    var itemCount: Int {
        return shoppingItems.values.reduce(0) { $0 + $1.count }
    }
    
    init() {
        print("📱 ShoppingListViewModel init")
        // Initialiser chaque catégorie avec un tableau vide
        for category in IngredientCategory.allCases {
            shoppingItems[category] = []
            print("  - Catégorie initialisée: \(category.rawValue)")
        }
    }
    
    // Générer la liste de courses à partir des recettes sélectionnées
    @MainActor
    func generateShoppingList(from recipes: [DetailedRecipe]) {
        // Nettoyer d'abord
        for category in IngredientCategory.allCases {
            shoppingItems[category] = []
        }

        var allItems: [ShoppingItem] = []
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

        let groupedItems = Dictionary(grouping: allItems) {
            "\($0.name.lowercased())-\($0.unit.lowercased())"
        }

        var categorizedMergedItems: [IngredientCategory: [ShoppingItem]] = [:]

        for (_, items) in groupedItems {
            guard let first = items.first else { continue }
            let totalQuantity = items.reduce(0) { $0 + $1.quantity }
            let rounded = (totalQuantity * 10).rounded() / 10

            let mergedItem = ShoppingItem(
                name: first.name,
                quantity: rounded,
                unit: first.unit,
                category: first.category
            )

            categorizedMergedItems[first.category, default: []].append(mergedItem)
        }

        // Trier chaque catégorie
        for category in IngredientCategory.allCases {
            categorizedMergedItems[category]?.sort { $0.name < $1.name }
        }

        // Injection progressive avec animation
        Task {
            for category in IngredientCategory.allCases {
                if let items = categorizedMergedItems[category] {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec
                    withAnimation(.easeOut(duration: 0.2)) {
                        shoppingItems[category] = items
                    }
                }
            }
        }
    }

    
    // Marquer un élément comme coché ou non coché
    func toggleItemCheck(item: ShoppingItem) {
        if let index = shoppingItems[item.category]?.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[item.category]?[index].isChecked.toggle()
        }
    }
    
    @MainActor
    func addCustomItem(name: String, quantity: Double, unit: String, category: IngredientCategory) async {
        // Normaliser le nom et l’unité pour comparaison
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedUnit = unit.lowercased()

        // Vérifier si un item identique existe déjà
        if var existingItems = shoppingItems[category] {
            if let index = existingItems.firstIndex(where: {
                $0.name.lowercased() == normalizedName && $0.unit.lowercased() == normalizedUnit
            }) {
                // Fusionner la quantité
                shoppingItems[category]?[index].quantity += quantity
                await saveCustomItems()
                return
            }
        }

        // Sinon, ajouter un nouvel item
        let newItem = ShoppingItem(
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            isChecked: false
        )

        shoppingItems[category, default: []].append(newItem)
        await saveCustomItems()
    }
    
    @MainActor
    func deleteItem(_ item: ShoppingItem) async {
        if var items = shoppingItems[item.category] {
            items.removeAll { $0.id == item.id }
            shoppingItems[item.category] = items
            await saveCustomItems()
        }
    }




    func saveCustomItems() async {
        do {
            try await localDataManager?.save(shoppingItems, forKey: "custom_shopping_items")
        } catch {
            print("❌ Erreur de sauvegarde des items custom : \(error)")
        }
    }
    
    // Vérifier si la liste est vide
    var isEmpty: Bool {
        return shoppingItems.values.allSatisfy { $0.isEmpty }
    }
    
    func setDependencies(localDataManager: LocalDataManager) {
        self.localDataManager = localDataManager
    }
}





