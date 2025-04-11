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
    @State private var otherRestriction: String = ""
    
    @EnvironmentObject var storeKit: StoreKitManager

    var isPremiumUser: Bool {
        storeKit.isPremiumUser
    }





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
                    mealTypeSection()
                    restrictionSection(isPremiumUser: storeKit.isPremiumUser)
                    
                    IngredientListSection(
                        title: "Ingrédients à utiliser",
                        text: $newPreferredIngredient,
                        list: $preferences.preferredIngredients
                    )

                    IngredientListSection(
                        title: "Ingrédients bannis",
                        text: $newBannedIngredient,
                        list: $preferences.bannedIngredients
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
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
    }
    @ViewBuilder
    private func mealTypeSection() -> some View {
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
    }

    @ViewBuilder
    private func restrictionSection(isPremiumUser: Bool) -> some View {
        sectionCard(title: "Restrictions alimentaires") {
            
            ForEach(DietaryRestriction.predefinedCases, id: \.self) { restriction in
                Toggle(restriction.displayName, isOn: Binding(
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
            Text(isPremiumUser ? "Autres" : "Autres (Premium)")
                .font(.headline)
            
            if isPremiumUser {
                TextField("Ex: Allergie aux arachides", text: Binding(
                    get: { preferences.otherRestriction ?? "" },
                    set: { preferences.otherRestriction = $0 }
                ))
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            } else {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    Text("Exclusif Premium")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            }
            
            if !isPremiumUser {
                Text("🔒 Disponible uniquement pour les membres Premium")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
        }
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
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
    }
}
