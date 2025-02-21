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
    @State private var numberOfDays = 1
    @State private var selectedMealTypes: Set<MealType> = [.lunch, .dinner]
    
    let onGenerate: (MealPreferences) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Configuration générale") {
                    Stepper("Portions : \(preferences.defaultServings)",
                           value: $preferences.defaultServings, in: 1...10)
                    
                    Stepper("Nombre de jours : \(numberOfDays)",
                           value: $numberOfDays, in: 1...7)
                }
                
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
                            }
                        ))
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
                    // On passe le nombre de jours et les types de repas sélectionnés
                    preferences.numberOfDays = numberOfDays
                    preferences.mealTypes = Array(selectedMealTypes)
                    onGenerate(preferences)
                    dismiss()
                }
            )
        }
    }
}
