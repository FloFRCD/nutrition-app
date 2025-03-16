//
//  PlanningView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct PlanningView: View {
    @EnvironmentObject private var localDataManager: LocalDataManager
    @StateObject private var viewModel: PlanningViewModel
    @State private var showingConfigSheet = false
    @State private var currentPreferences: MealPreferences?
    @State private var selectedMealTypes: Set<MealType> = [.breakfast, .lunch, .dinner, .snack]
    @State private var selectedMealIDs: Set<UUID> = [] // Stocke les IDs au lieu des objets
    @State private var showingDetailedRecipes = false
    @State private var forceRefresh = UUID()
    
    init() {
        _viewModel = StateObject(wrappedValue: PlanningViewModel())
    }
    
    var groupedSuggestions: [String: [AIMeal]] {
        Dictionary(grouping: viewModel.mealSuggestions) { $0.type }
    }
    
    // Calcule les repas sélectionnés à partir des IDs
    var selectedMealSuggestions: [AIMeal] {
        return viewModel.mealSuggestions.filter { selectedMealIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.mealSuggestions.isEmpty {
                    ContentUnavailableView(
                        "Aucune suggestion de repas",
                        systemImage: "fork.knife",
                        description: Text("Appuyez sur + pour générer des suggestions de repas")
                    )
                } else {
                    VStack(spacing: 20) {
                        // Afficher les suggestions de repas par type
                        ForEach(Array(groupedSuggestions.keys.sorted()), id: \.self) { mealType in
                            if let suggestions = groupedSuggestions[mealType], !suggestions.isEmpty {
                                MealSuggestionSection(
                                    mealType: mealType,
                                    suggestions: suggestions,
                                    selectedIDs: $selectedMealIDs // Passer les IDs au lieu des objets
                                )
                                .id("\(mealType)_\(forceRefresh.uuidString)") // Forcer le rafraîchissement
                            }
                        }
                        
                        // Afficher le bouton pour obtenir les détails
                        if !selectedMealSuggestions.isEmpty {
                            Button(action: {
                                showingDetailedRecipes = true
                            }) {
                                Text("Obtenir les détails (\(selectedMealSuggestions.count)/4)")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedMealSuggestions.count <= 4 ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(selectedMealSuggestions.count > 4)
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Suggestions de repas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Initialiser les préférences avec les données utilisateur si nécessaire
                        if currentPreferences == nil {
                            currentPreferences = createDefaultPreferences()
                        }
                        showingConfigSheet = true
                    } label: {
                        Label("Générer", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingConfigSheet) {
                if let unwrappedPreferences = currentPreferences {
                    MealConfigurationSheet(
                        preferences: Binding(
                            get: { unwrappedPreferences },
                            set: { self.currentPreferences = $0 }
                        ),
                        onGenerate: { preferences in
                            // Reset selected suggestions
                            selectedMealIDs = []
                            
                            // Déboguer les préférences
                            print("=== PRÉFÉRENCES AVANT GÉNÉRATION (CAS 1 PLANNING VIEW) ===")
                            print("Types de repas:", preferences.mealTypes.map { $0.rawValue })
                            print("Recettes par type:", preferences.recipesPerType)
                            print("Total attendu:", preferences.mealTypes.count * preferences.recipesPerType)
                            print("===================================")
                            
                            Task {
                                await viewModel.generateMealSuggestions(with: preferences)
                            }
                        }
                    )
                } else {
                    // Créer des préférences par défaut si elles n'existent pas
                    let defaultPrefs = createDefaultPreferences()
                    MealConfigurationSheet(
                        preferences: Binding(
                            get: { defaultPrefs },
                            set: { self.currentPreferences = $0 }
                        ),
                        onGenerate: { preferences in
                            // Reset selected suggestions
                            selectedMealIDs = []
                            
                            // Déboguer les préférences
                            print("=== PRÉFÉRENCES AVANT GÉNÉRATION (CAS 2 PLANNING VIEW) ===")
                            print("Types de repas:", preferences.mealTypes.map { $0.rawValue })
                            print("Recettes par type:", preferences.recipesPerType)
                            print("Total attendu:", preferences.mealTypes.count * preferences.recipesPerType)
                            print("===================================")
                            
                            Task {
                                await viewModel.generateMealSuggestions(with: preferences)
                            }
                        }
                    )
                }
            }
            
            .sheet(isPresented: $showingDetailedRecipes) {
                if !selectedMealSuggestions.isEmpty {
                    DetailedRecipesView(
                        recipes: selectedMealSuggestions,
                        onDismiss: { showingDetailedRecipes = false }
                    )
                }
            }
        }
        .onAppear {
            viewModel.setDependencies(localDataManager: localDataManager, aiService: AIService.shared)
            // Forcer le rafraîchissement à chaque apparition
            forceRefresh = UUID()
        }
    }
    
    private func createDefaultPreferences() -> MealPreferences {
        let userProfile = localDataManager.userProfile ?? UserProfile.default
        let prefs = MealPreferences(
            bannedIngredients: [],
            preferredIngredients: [],
            defaultServings: 1,
            dietaryRestrictions: [],
            mealTypes: Array(selectedMealTypes),
            recipesPerType: 12 / max(selectedMealTypes.count, 1), // Calcul dynamique
            userProfile: userProfile
        )
        print("recipesPerType dans createDefaultPreferences:", prefs.recipesPerType)
        return prefs
    }
}

// Vue pour afficher les suggestions par type de repas
struct MealSuggestionSection: View {
    let mealType: String
    let suggestions: [AIMeal]
    @Binding var selectedIDs: Set<UUID> // Modifier pour utiliser des IDs
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(mealType)
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(suggestions) { suggestion in
                MealSuggestionCard(
                    suggestion: suggestion,
                    isSelected: selectedIDs.contains(suggestion.id), // Vérifier avec l'ID
                    onToggle: { selected in
                        if selected {
                            selectedIDs.insert(suggestion.id) // Insérer l'ID
                        } else {
                            selectedIDs.remove(suggestion.id) // Supprimer l'ID
                        }
                    }
                )
            }
        }
    }
}

// Carte pour une suggestion de repas individuelle
struct MealSuggestionCard: View {
    let suggestion: AIMeal
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    // État local pour gérer l'affichage
    @State private var localIsSelected: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(suggestion.name)
                        .font(.title3)
                        .bold()
                    
                    Text(suggestion.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkbox pour sélectionner cette recette
                Button(action: {
                    localIsSelected.toggle() // Changer l'état local immédiatement
                    onToggle(!isSelected)    // Propager le changement
                }) {
                    Image(systemName: localIsSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(localIsSelected ? .blue : .gray)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(localIsSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
        .onAppear {
            // Synchroniser l'état local avec l'état reçu lors de l'apparition
            localIsSelected = isSelected
        }
        .onChange(of: isSelected) { newValue in
            // Mettre à jour l'état local quand l'état externe change
            localIsSelected = newValue
        }
    }
}

// Extension pour créer un profil utilisateur par défaut
extension UserProfile {
    static var `default`: UserProfile {
        UserProfile(
            name: "Utilisateur",
            age: 30,
            gender: .male,
            height: 170,
            weight: 70,
            bodyFatPercentage: nil,
            fitnessGoal: .maintainWeight,
            activityLevel: .moderatelyActive,
            dietaryRestrictions: [],
            activityDetails: ActivityDetails(
                exerciseDaysPerWeek: 3,
                exerciseDuration: 45,
                exerciseIntensity: .moderate,
                jobActivity: .seated,
                dailyActivity: .moderate
            )
        )
    }
}
