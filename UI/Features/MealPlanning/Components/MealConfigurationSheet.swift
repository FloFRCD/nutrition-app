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

    @State private var selectedMealTypes: Set<MealType>
    @State private var newBannedIngredient = ""
    @State private var newPreferredIngredient = ""
    @State private var promptOverride = ""

    @State private var selectedGoal: MealGoal?
    @State private var selectedCuisines: Set<CuisineType> = []
    @State private var selectedFormats: Set<MealFormat> = []

    @EnvironmentObject var storeKit: StoreKitManager

    @State private var expandMeals = true
    @State private var expandGoal = false
    @State private var expandCuisines = false
    @State private var expandFormats = false
    @State private var expandRestrictions = false
    @State private var expandPreferred = false
    @State private var expandBanned = false
    @State private var expandPrompt = false

    var isPremiumUser: Bool { storeKit.isPremiumUser }

    let totalSuggestions = 12
    let onGenerate: (MealPreferences) -> Void

    init(preferences: Binding<MealPreferences>, onGenerate: @escaping (MealPreferences) -> Void) {
        self._preferences = preferences
        self.onGenerate = onGenerate
        self._selectedMealTypes = State(initialValue: Set(preferences.wrappedValue.mealTypes))
        self._selectedGoal = State(initialValue: preferences.wrappedValue.mealGoal)
        self._selectedCuisines = State(initialValue: Set(preferences.wrappedValue.cuisineTypes ?? []))
        self._selectedFormats = State(initialValue: Set(preferences.wrappedValue.mealFormats ?? []))
        self._promptOverride = State(initialValue: preferences.wrappedValue.promptOverride ?? "")
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
                    preferences.mealTypes = Array(selectedMealTypes)
                    preferences.recipesPerType = recipesPerType
                    preferences.mealGoal = selectedGoal
                    preferences.cuisineTypes = Array(selectedCuisines)
                    preferences.mealFormats = Array(selectedFormats)
                    preferences.promptOverride = promptOverride.isEmpty ? nil : promptOverride
                    onGenerate(preferences)
                    dismiss()
                }
                .disabled(selectedMealTypes.isEmpty)
            }
            .padding()
            .background(Color.white)
            .overlay(Divider(), alignment: .bottom)

            ScrollView {
                VStack(spacing: 16) {
                    mealTypeSection()
                    goalSection()
                    cuisineSection()
                    formatSection()
                    restrictionSection()
                    preferredIngredientsSection()
                    bannedIngredientsSection()
                    if isPremiumUser { promptOverrideSection() }
                }
                .padding()
            }
            .background(Color.white)
        }
        .foregroundColor(.black)
        .background(Color.white)
    }

    private func mealTypeSection() -> some View {
        collapsibleSection(title: "Type de repas", isExpanded: $expandMeals) {
            ForEach(MealType.allCases, id: \.self) { type in
                Toggle(type.rawValue, isOn: Binding(
                    get: { selectedMealTypes.contains(type) },
                    set: { isOn in
                        if isOn { selectedMealTypes.insert(type) }
                        else { selectedMealTypes.remove(type) }
                    }
                ))
                .toggleStyle(.gradient)
            }
            if !selectedMealTypes.isEmpty {
                Text("Recettes par type: \(recipesPerType)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }

    private func goalSection() -> some View {
        collapsibleSection(title: "Objectif du repas", isExpanded: $expandGoal) {
            Picker("Objectif", selection: $selectedGoal) {
                Text("Aucun").tag(MealGoal?.none)
                ForEach(MealGoal.allCases) { goal in
                    Text(goal.rawValue).tag(Optional(goal))
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    private func cuisineSection() -> some View {
        collapsibleSection(title: "Origine culinaire", isExpanded: $expandCuisines) {
            ForEach(CuisineType.allCases) { cuisine in
                Toggle(cuisine.rawValue, isOn: Binding(
                    get: { selectedCuisines.contains(cuisine) },
                    set: { isOn in
                        if isOn { selectedCuisines.insert(cuisine) }
                        else { selectedCuisines.remove(cuisine) }
                    }
                ))
                .toggleStyle(.gradient)
            }
        }
    }

    private func formatSection() -> some View {
        collapsibleSection(title: "Format de plat", isExpanded: $expandFormats) {
            ForEach(MealFormat.allCases) { format in
                Toggle(format.rawValue, isOn: Binding(
                    get: { selectedFormats.contains(format) },
                    set: { isOn in
                        if isOn { selectedFormats.insert(format) }
                        else { selectedFormats.remove(format) }
                    }
                ))
                .toggleStyle(.gradient)
            }
        }
    }

    private func restrictionSection() -> some View {
        collapsibleSection(title: "Régime alimentaires", isExpanded: $expandRestrictions) {
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
                .toggleStyle(.gradient)
            }
            if isPremiumUser {
                TextField("Autres (ex: allergie aux arachides)", text: Binding(
                    get: { preferences.otherRestriction ?? "" },
                    set: { preferences.otherRestriction = $0 }
                ))
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Autres - Premium uniquement")
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }

    private func preferredIngredientsSection() -> some View {
        collapsibleSection(title: "Ingrédients à utiliser", isExpanded: $expandPreferred) {
            VStack(spacing: 12) {
                HStack {
                    TextField("Nouvel ingrédient", text: $newPreferredIngredient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Ajouter") {
                        if !newPreferredIngredient.isEmpty {
                            preferences.preferredIngredients.append(newPreferredIngredient)
                            newPreferredIngredient = ""
                        }
                    }
                    .disabled(newPreferredIngredient.isEmpty)
                }
                IngredientItemList(title: "", list: $preferences.preferredIngredients)
            }
        }
    }

    private func bannedIngredientsSection() -> some View {
        collapsibleSection(title: "Ingrédients bannis", isExpanded: $expandBanned) {
            VStack(spacing: 12) {
                HStack {
                    TextField("Nouvel ingrédient", text: $newBannedIngredient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Ajouter") {
                        if !newBannedIngredient.isEmpty {
                            preferences.bannedIngredients.append(newBannedIngredient)
                            newBannedIngredient = ""
                        }
                    }
                    .disabled(newBannedIngredient.isEmpty)
                }
                IngredientItemList(title: "", list: $preferences.bannedIngredients)
            }
        }
    }

    private func promptOverrideSection() -> some View {
        collapsibleSection(title: "Prompt personnalisé", isExpanded: $expandPrompt) {
            PromptOverrideSection(
                promptText: $promptOverride,
                isEnabled: $preferences.isPromptOverrideEnabled,
                isPremiumUser: isPremiumUser,
                onUseExample: {
                    promptOverride = "Génère-moi des plats très rapides à préparer, pauvres en glucides et sans cuisson."
                }
            )
        }
    }

    
    // MARK: - Collapsible Section
    
    @ViewBuilder
    private func collapsibleSection<Content: View>(title: String, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isExpanded.wrappedValue.toggle()
                    }
                }) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                if isExpanded.wrappedValue {
                    VStack(alignment: .leading, spacing: 12) {
                        content()
                    }
                    .padding([.horizontal, .bottom])
                    .transition(.opacity)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.horizontal, 4)
    }
}
    extension ToggleStyle where Self == GradientToggleStyle {
        static var gradient: GradientToggleStyle {
            GradientToggleStyle()
        }
    }

    struct GradientToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.label
                Spacer()
                ZStack {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 51, height: 31)

                    if configuration.isOn {
                        Capsule()
                            .fill(AppTheme.primaryButtonGradient)
                            .frame(width: 51, height: 31)
                            .animation(.easeInOut, value: configuration.isOn)
                    }

                    Circle()
                        .fill(Color.white)
                        .frame(width: 27, height: 27)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .shadow(radius: 1)
                        .animation(.easeInOut, value: configuration.isOn)
                }
                .onTapGesture { configuration.isOn.toggle() }
            }
        }
    }

struct IngredientItemList: View {
    let title: String
    @Binding var list: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
            }
            ForEach(list, id: \.self) { item in
                HStack {
                    Text("• \(item)")
                    Spacer()
                    Button(action: {
                        withAnimation {
                            list.removeAll { $0 == item }
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }
}

struct PromptOverrideSection: View {
    @Binding var promptText: String
    @Binding var isEnabled: Bool
    let isPremiumUser: Bool
    let onUseExample: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Mon prompt")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(.gradient)
                    .labelsHidden()
                    .disabled(!isPremiumUser)
            }

            if isPremiumUser {
                if isEnabled {
                    Text("Rédige ton propre prompt pour générer des repas personnalisés. Laisse vide pour utiliser les paramètres ci-dessus. La section 'Type de repas' reste prise en compte.")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    TextEditor(text: $promptText)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Button("Utiliser un exemple de prompt") {
                        onUseExample?()
                    }
                    .font(.footnote)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    Text("Disponible pour les membres Premium")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
