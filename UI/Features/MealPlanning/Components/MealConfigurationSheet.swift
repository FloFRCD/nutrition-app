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

    private let totalSuggestions = 12
    let onGenerate: (MealPreferences) -> Void

    init(preferences: Binding<MealPreferences>, onGenerate: @escaping (MealPreferences) -> Void) {
        self._preferences = preferences
        self.onGenerate = onGenerate
        self._selectedMealTypes = State(initialValue: Set(preferences.wrappedValue.mealTypes))
    }

    private var recipesPerType: Int {
        let count = selectedMealTypes.count
        return count > 0 ? totalSuggestions / count : 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button("Annuler") { dismiss() }
                Spacer()
                Button("Générer") {
                    preferences.recipesPerType = recipesPerType
                    onGenerate(preferences)
                    dismiss()
                }
                .disabled(selectedMealTypes.isEmpty)
            }
            .padding()
            .background(.white)
            .overlay(Divider(), alignment: .bottom)

            ScrollView {
                VStack(spacing: 20) {
                    sectionCard(title: "Repas à générer") {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Toggle(mealType.rawValue, isOn: Binding(
                                get: { selectedMealTypes.contains(mealType) },
                                set: { isOn in
                                    if isOn {
                                        selectedMealTypes.insert(mealType)
                                    } else {
                                        selectedMealTypes.remove(mealType)
                                    }
                                    preferences.mealTypes = Array(selectedMealTypes)
                                }
                            ))
                        }

                        if !selectedMealTypes.isEmpty {
                            Text("Recettes par type: \(recipesPerType)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }

                    sectionCard(title: "Restrictions alimentaires") {
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

                    IngredientListSection(
                        title: "Ingrédients bannis",
                        text: $newBannedIngredient,
                        list: $preferences.bannedIngredients
                    )

                    IngredientListSection(
                        title: "Ingrédients préférés",
                        text: $newPreferredIngredient,
                        list: $preferences.preferredIngredients
                    )
                }
                .padding()
            }
            .background(Color.white)
        }
        .presentationDetents([.large])
    }

    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)

            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: AppTheme.logoGreen.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}

struct IngredientListSection: View {
    let title: String
    @Binding var text: String
    @Binding var list: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                TextField("Nouvel ingrédient", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Ajouter") {
                    if !text.isEmpty {
                        list.append(text)
                        text = ""
                    }
                }
                .disabled(text.isEmpty)
            }

            ForEach(list, id: \.self) { item in
                Text("• \(item)")
            }
            .onDelete { indexSet in
                list.remove(atOffsets: indexSet)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: AppTheme.logoGreen.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}
