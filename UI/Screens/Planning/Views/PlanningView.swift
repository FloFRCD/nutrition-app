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
    @State private var isGeneratingDetails = false
    @State private var forceRefresh = UUID()
    
    // État pour le sélecteur de vues
    @State private var selectedTab: Int = 0
    
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
            VStack(spacing: 0) {
                // Sélecteur d'onglets
                ConsistentTabView(
                    selection: $selectedTab,
                    titles: ["Suggestions de repas", "Recettes sélectionnées"]
                )
                
                // TabView qui permet le swipe
                TabView(selection: $selectedTab) {
                    // Onglet 1: Suggestions avec bouton fixé en bas
                    ZStack(alignment: .bottom) {
                        suggestionsContent
                            .padding(.bottom, 60) // Espace pour le bouton fixe
                        
                        // Bouton fixé en bas
                            detailsButton
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                                .background(
                                    Rectangle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2)
                                )
                    }
                    .tag(0)
                    
                    // Onglet 2: Recettes sélectionnées
                    SavedRecipesView()
                        .environmentObject(localDataManager)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Planning repas")
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
                            
                            Task {
                                await viewModel.generateMealSuggestions(with: preferences)
                            }
                        }
                    )
                }
            }
            
            // Overlay de génération des détails
            .overlay(
                ZStack {
                    if isGeneratingDetails {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 15) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Génération des détails...")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Veuillez patienter")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.systemGray5).opacity(0.8))
                        .cornerRadius(10)
                    }
                }
            )
        }
        .onAppear {
            viewModel.setDependencies(localDataManager: localDataManager, aiService: AIService.shared)
            // Forcer le rafraîchissement à chaque apparition
            forceRefresh = UUID()
        }
    }
    
    // Contenu des suggestions de repas (sans le bouton)
    var suggestionsContent: some View {
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
                    
                    // Ajouter un espace vide en bas pour éviter que le contenu ne soit caché par le bouton fixe
                    Color.clear
                        .frame(height: 20)
                }
                .padding()
            }
        }
    }
    
    // Bouton "Obtenir les détails" extrait en propriété séparée
    var detailsButton: some View {
        Button(action: {
            generateAndSaveDetails()
        }) {
            Text("Obtenir les détails (\(selectedMealSuggestions.count)/4)")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonBackgroundColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(selectedMealSuggestions.isEmpty || selectedMealSuggestions.count > 4)
    }
    
    private var buttonBackgroundColor: Color {
        if selectedMealSuggestions.isEmpty || selectedMealSuggestions.count > 4 {
            return Color.gray // Grisé si vide ou trop de sélections
        } else {
            return Color.blue // Bleu si le nombre de sélections est valide (1-4)
        }
    }
    
    // Fonction qui génère les détails et bascule directement vers l'onglet des recettes sauvegardées
    private func generateAndSaveDetails() {
        Task {
            // Activer l'indicateur de chargement
            await MainActor.run {
                isGeneratingDetails = true
            }
            
            // 1. Générer les détails des recettes
            if let userProfile = localDataManager.userProfile {
                await generateRecipeDetails(userProfile: userProfile)
            } else {
                await generateRecipeDetails(userProfile: UserProfile.default)
            }
            
            // 2. Désactiver l'indicateur de chargement et basculer vers l'onglet "Recettes sélectionnées"
            await MainActor.run {
                isGeneratingDetails = false
                
                // Basculer vers l'onglet "Recettes sélectionnées"
                withAnimation {
                    selectedTab = 1
                }
            }
        }
    }
    
    // Fonction qui génère les détails des recettes et les sauvegarde directement
    private func generateRecipeDetails(userProfile: UserProfile) async {
        // Créer un ViewModel temporaire pour générer les détails
        let detailsViewModel = DetailedRecipesViewModel()
        
        // Générer les détails
        await detailsViewModel.fetchRecipeDetails(
            for: selectedMealSuggestions,
            userProfile: userProfile
        )
        
        // Si des recettes ont été générées, les sauvegarder
        if !detailsViewModel.detailedRecipes.isEmpty {
            await saveGeneratedRecipes(detailsViewModel.detailedRecipes)
        }
    }
    
    // Fonction qui sauvegarde les recettes générées
    private func saveGeneratedRecipes(_ recipes: [DetailedRecipe]) async {
        do {
            // Récupérer les recettes existantes
            var existingRecipes: [DetailedRecipe] = []
            if let savedRecipes: [DetailedRecipe] = try? await localDataManager.load(forKey: "saved_detailed_recipes") {
                existingRecipes = savedRecipes
            }
            
            // Ajouter les nouvelles recettes en évitant les doublons
            var updatedRecipes = existingRecipes
            var newRecipesCount = 0
            
            for recipe in recipes {
                // Vérifier si la recette n'existe pas déjà par son nom
                if !updatedRecipes.contains(where: { $0.name == recipe.name }) {
                    updatedRecipes.append(recipe)
                    newRecipesCount += 1
                }
            }
            
            // Sauvegarder la liste mise à jour
            try await localDataManager.save(updatedRecipes, forKey: "saved_detailed_recipes")
            print("✅ Sauvegarde directe: \(newRecipesCount) nouvelles recettes sauvegardées (total: \(updatedRecipes.count))")
            
            // Notifier que des recettes ont été ajoutées
            NotificationCenter.default.post(name: NSNotification.Name("RecipeDeleted"), object: nil)
            
        } catch {
            print("❌ Erreur lors de la sauvegarde directe: \(error)")
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
        return prefs
    }
}

// Définir les onglets disponibles
enum PlanningTab {
    case suggestions
    case savedRecipes
}

struct ConsistentTabView: View {
    @Binding var selection: Int
    let titles: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<titles.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selection = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(titles[index])
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(selection == index ? .primary : .gray)
                        
                        // Ligne sous le texte
                        Rectangle()
                            .fill(selection == index ? Color.blue : Color.clear)
                            .frame(height: 3)
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}

// Bouton d'onglet personnalisé
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.bottom, 5)
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
