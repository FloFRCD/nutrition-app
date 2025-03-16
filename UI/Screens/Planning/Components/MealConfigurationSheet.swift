//
//  MealConfigurationSheet.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/02/2025.
//

import Foundation
import SwiftUI


struct MealConfigurationSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var preferences: MealPreferences
    @State private var newBannedIngredient = ""
    @State private var newPreferredIngredient = ""
    @State private var selectedMealTypes: Set<MealType>
    
    // Constante pour le nombre total de suggestions
    private let totalSuggestions = 12
    
    let onGenerate: (MealPreferences) -> Void
    
    init(preferences: Binding<MealPreferences>, onGenerate: @escaping (MealPreferences) -> Void) {
        self._preferences = preferences
        self.onGenerate = onGenerate
        // Initialisez selectedMealTypes avec les types actuellement sélectionnés
        self._selectedMealTypes = State(initialValue: Set(preferences.wrappedValue.mealTypes))
    }
    
    // Calcul du nombre de recettes par type
    private var recipesPerType: Int {
        let totalSuggestions = 12 // Nombre total fixe de suggestions
        let selectedTypesCount = selectedMealTypes.count
        return selectedTypesCount > 0 ? totalSuggestions / selectedTypesCount : 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Repas à générer") {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Toggle(mealType.rawValue, isOn: Binding(
                            get: { selectedMealTypes.contains(mealType) },
                            set: { isOn in
                                if isOn {
                                    selectedMealTypes.insert(mealType)
                                } else {
                                    selectedMealTypes.remove(mealType)
                                }
                                
                                // Important: Mise à jour immédiate de preferences.mealTypes
                                preferences.mealTypes = Array(selectedMealTypes)
                            }
                        ))
                    }
                    
                    if !selectedMealTypes.isEmpty {
                        Text("Recettes par type: \(recipesPerType)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Restrictions alimentaires") {
                    ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                        Toggle(restriction.rawValue, isOn: Binding(
                            get: { preferences.dietaryRestrictions.contains(restriction) },
                            set: { isOn in
                                if isOn {
                                    preferences.dietaryRestrictions.append(restriction)
                                } else {
                                    preferences.dietaryRestrictions.removeAll { $0 == restriction }
                                }
                            }
                        ))
                    }
                }
                
                Section("Ingrédients bannis") {
                    HStack {
                        TextField("Nouvel ingrédient", text: $newBannedIngredient)
                        Button("Ajouter") {
                            if !newBannedIngredient.isEmpty {
                                preferences.bannedIngredients.append(newBannedIngredient)
                                newBannedIngredient = ""
                            }
                        }
                        .disabled(newBannedIngredient.isEmpty)
                    }
                    
                    ForEach(preferences.bannedIngredients, id: \.self) { ingredient in
                        Text(ingredient)
                    }
                    .onDelete { indexSet in
                        preferences.bannedIngredients.remove(atOffsets: indexSet)
                    }
                }
                
                Section("Ingrédients préférés") {
                    HStack {
                        TextField("Nouvel ingrédient", text: $newPreferredIngredient)
                        Button("Ajouter") {
                            if !newPreferredIngredient.isEmpty {
                                preferences.preferredIngredients.append(newPreferredIngredient)
                                newPreferredIngredient = ""
                            }
                        }
                        .disabled(newPreferredIngredient.isEmpty)
                    }
                    
                    ForEach(preferences.preferredIngredients, id: \.self) { ingredient in
                        Text(ingredient)
                    }
                    .onDelete { indexSet in
                        preferences.preferredIngredients.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Configuration")
                        .navigationBarItems(
                            leading: Button("Annuler") { dismiss() },
                            trailing: Button("Générer") {
                                print("recipesPerType avant calcul:", preferences.recipesPerType)
                                
                                // Calculer et définir dynamiquement le nombre de recettes par type
                                let totalSuggestions = 12
                                let newRecipesPerType = selectedMealTypes.count > 0 ? totalSuggestions / selectedMealTypes.count : 0
                                preferences.recipesPerType = newRecipesPerType
                                
                                print("recipesPerType après calcul:", preferences.recipesPerType)
                                onGenerate(preferences)
                                
                                // Fermer la feuille de configuration
                                   dismiss()
                            }
                                .disabled(selectedMealTypes.isEmpty)
                        )
                    }
                }
            }
