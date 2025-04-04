//
//  AddCustomShoppingItem.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation
import SwiftUI

struct AddCustomShoppingItemSheet: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var quantity = ""
    @State private var selectedCategory: IngredientCategory = .other
    @State private var selectedUnit: String = "g"

    let onAdd: (String, Double, String, IngredientCategory) -> Void

    let availableUnits = ["g", "kg", "ml", "l", "càc", "càs", "pièce", "tranche"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nom")) {
                    TextField("Nom de l’ingrédient", text: $name)
                }

                Section(header: Text("Quantité")) {
                    HStack {
                        TextField("Ex: 250", text: $quantity)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)

                        Picker("Unité", selection: $selectedUnit) {
                            ForEach(availableUnits, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                Section(header: Text("Catégorie")) {
                    Picker("Catégorie", selection: $selectedCategory) {
                        ForEach(IngredientCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Ajouter un ingrédient")
            .navigationBarItems(
                leading: Button("Annuler") {
                    dismiss()
                },
                trailing: Button("Ajouter") {
                    guard let qty = Double(quantity), !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    onAdd(name, qty, selectedUnit, selectedCategory)
                    dismiss()
                }
                .disabled(name.isEmpty || quantity.isEmpty)
            )
        }
    }
}

