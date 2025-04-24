//
//  NutriaFoodSeacrhView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 22/04/2025.
//

import Foundation
import SwiftUI

struct NutriaFoodSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var nutritionService: NutritionService

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var quantity: String = "100"
    @State private var isLoading = false
    @State private var foundFood: NutriaFood? = nil
    @State private var errorMessage: String? = nil
    @State private var selectedUnit: ServingUnit = .gram

    let onFoodSelected: (NutriaFood, Double, ServingUnit) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nom de l’aliment")) {
                    TextField("Concombre", text: $name)
                        .onSubmit { search() }
                }

                Section(header: Text("Marque (facultatif)")) {
                    TextField("Ex: Ferrero", text: $brand)
                }

                Section(header: Text("Quantité")) {
                    TextField("100", text: $quantity)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Unité")) {
                    Picker("Unité", selection: $selectedUnit) {
                        ForEach(ServingUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                if let food = foundFood {
                    Section(header: Text("Aperçu")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(food.canonicalName).font(.headline)
                            Text("Calories : \(Int(food.calories)) kcal")
                            Text("Protéines : \(food.proteins, specifier: "%.1f")g")
                            Text("Glucides : \(food.carbs, specifier: "%.1f")g")
                            Text("Lipides : \(food.fats, specifier: "%.1f")g")
                            Text("Portion : \(Int(food.servingSize)) \(food.servingUnit)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let error = errorMessage {
                    Section {
                        Text("❌ \(error)")
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button("Rechercher") {
                        search()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).count < 2)
                    
                    if let food = foundFood {
                        Button("Ajouter") {
                            if let food = foundFood, let qty = Double(quantity), qty > 0 {
                              onFoodSelected(food, qty, selectedUnit)
                              presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recherche intelligente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func search() {
      guard name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
        errorMessage = "Veuillez entrer un nom valide"
        return
      }
      errorMessage = nil
      foundFood = nil
      isLoading = true

      Task {
        defer { isLoading = false }
        do {
          // 1) Récupère le JSON brut (ou le génère + stocke)
          let rawJSON = try await nutritionService.fetchOrGenerateRawJSON(
            for: name,
            unit: selectedUnit
          )
          // 2) Décodage en NutritionInfo
          let info = try JSONDecoder()
            .decode(NutritionInfo.self, from: Data(rawJSON.utf8))

          // 3) Convertis en NutriaFood ou garde juste les infos nécessaires
          let food = NutriaFood(
            id: UUID().uuidString,
            canonicalName: name,
            normalizedName: name.lowercased().folding(options: .diacriticInsensitive, locale: .current),
            brand:         brand.isEmpty ? nil : brand,
            normalizedBrand: brand.isEmpty ? nil : brand.lowercased().folding(options: .diacriticInsensitive, locale: .current),
            isGeneric:     brand.isEmpty,
            servingSize:   info.servingSize,
            servingUnit:   info.servingUnit,
            calories:      info.calories,
            proteins:      info.proteins,
            carbs:         info.carbs,
            fats:          info.fats,
            fiber:         info.fiber,
            source:        "gpt-4o",
            createdAt: Date()
          )
          foundFood = food

        } catch {
          errorMessage = "Erreur : \(error.localizedDescription)"
        }
      }
    }

}

