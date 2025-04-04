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
    @StateObject private var viewModel = PlanningViewModel()
    
    @State private var showingConfigSheet = false
    @State private var currentPreferences: MealPreferences?
    @State private var selectedMealTypes: Set<MealType> = [.breakfast, .lunch, .dinner, .snack]
    @State private var selectedMealIDs: Set<UUID> = []
    @State private var isGeneratingDetails = false
    @State private var selectedTab: Int = 0
    @State private var forceRefresh = UUID()
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                VStack(spacing: 0) {
                    Image("Icon-scan")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(.top, 70)
                    
                    // Espacement minimal pour remonter le contenu
                    Spacer(minLength: 0)
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ConsistentTabView(
                                selection: $selectedTab,
                                titles: ["Suggestions", "Recettes", "Sélection", "Liste des courses"]
                            )
                            .padding(.top, 8)
                            
                            TabView(selection: $selectedTab) {
                                ZStack(alignment: .bottom) {
                                    suggestionsContent
                                        .padding(.bottom, 100)
                                    
                                    detailsButton
                                        .padding(.horizontal)
                                        .padding(.bottom, 20)
                                }
                                .tag(0)
                                
                                SavedRecipesView()
                                    .environmentObject(localDataManager)
                                    .tag(1)
                                
                                SelectedRecipesView()
                                    .environmentObject(localDataManager)
                                    .tag(2)
                                
                                ShoppingListWrapper(isActive: selectedTab == 3)
                                    .environmentObject(localDataManager)
                                    .tag(3)
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        }
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
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
                    .background(Color(.systemGray5).opacity(0.9))
                    .cornerRadius(12)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
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
                MealConfigurationSheet(
                    preferences: currentPreferencesBinding,
                    onGenerate: { preferences in
                        selectedMealIDs = []
                        Task {
                            await viewModel.generateMealSuggestions(with: preferences)
                        }
                    }
                )
            }
            .onAppear {
                viewModel.setDependencies(localDataManager: localDataManager, aiService: AIService.shared)
                forceRefresh = UUID()
            }
        }
    }
    
    private var groupedSuggestions: [String: [AIMeal]] {
        Dictionary(grouping: viewModel.mealSuggestions) { $0.type }
    }
    
    private var selectedMealSuggestions: [AIMeal] {
        viewModel.mealSuggestions.filter { selectedMealIDs.contains($0.id) }
    }
    private var currentPreferencesBinding: Binding<MealPreferences> {
        Binding(
            get: { currentPreferences ?? createDefaultPreferences() },
            set: { self.currentPreferences = $0 }
        )
    }

    private var suggestionsContent: some View {
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
                    ForEach(groupedSuggestions.keys.sorted(), id: \.self) { mealType in
                        if let suggestions = groupedSuggestions[mealType], !suggestions.isEmpty {
                            MealSuggestionSection(
                                mealType: mealType,
                                suggestions: suggestions,
                                selectedIDs: $selectedMealIDs
                            )
                            .id("\(mealType)_\(forceRefresh.uuidString)")
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 80) // pour laisser de l’espace à la tabbar

            }
        }
    }
    
    private var detailsButton: some View {
        Button {
            generateAndSaveDetails()
        } label: {
            Text("Obtenir les détails (\(selectedMealSuggestions.count)/4)")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if selectedMealSuggestions.isEmpty || selectedMealSuggestions.count > 4 {
                            AnyView(Color.gray.opacity(0.4))
                        } else {
                            AnyView(AppTheme.primaryButtonGradient)
                        }
                    }
                )

                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
        }
        .disabled(selectedMealSuggestions.isEmpty || selectedMealSuggestions.count > 4)
        .padding(.horizontal)
        .padding(.bottom, 80)
    }
    
    private func generateAndSaveDetails() {
        Task {
            await MainActor.run { isGeneratingDetails = true }
            
            let profile = localDataManager.userProfile ?? .default
            let detailsVM = DetailedRecipesViewModel()
            await detailsVM.fetchRecipeDetails(for: selectedMealSuggestions, userProfile: profile)
            
            if !detailsVM.detailedRecipes.isEmpty {
                await saveGeneratedRecipes(detailsVM.detailedRecipes)
            }
            
            await MainActor.run {
                isGeneratingDetails = false
                withAnimation { selectedTab = 1 }
            }
        }
    }
    
    private func saveGeneratedRecipes(_ recipes: [DetailedRecipe]) async {
        do {
            var existing: [DetailedRecipe] = (try? await localDataManager.load(forKey: "saved_detailed_recipes")) ?? []
            let newRecipes = recipes.filter { new in
                !existing.contains(where: { $0.name == new.name })
            }
            existing.append(contentsOf: newRecipes)
            try await localDataManager.save(existing, forKey: "saved_detailed_recipes")
            NotificationCenter.default.post(name: .init("RecipeDeleted"), object: nil)
        } catch {
            print("❌ Erreur de sauvegarde des recettes: \(error)")
        }
    }
    
    private func createDefaultPreferences() -> MealPreferences {
        let profile = localDataManager.userProfile ?? .default
        return MealPreferences(
            bannedIngredients: [],
            preferredIngredients: [],
            defaultServings: 1,
            dietaryRestrictions: [],
            mealTypes: Array(selectedMealTypes),
            recipesPerType: 12 / max(selectedMealTypes.count, 1),
            userProfile: profile
        )
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
    @Binding var selectedIDs: Set<UUID>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mealType)
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(suggestions) { suggestion in
                    MealSuggestionCard(
                        suggestion: suggestion,
                        isSelected: selectedIDs.contains(suggestion.id),
                        onToggle: { selected in
                            if selected {
                                selectedIDs.insert(suggestion.id)
                            } else {
                                selectedIDs.remove(suggestion.id)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal) // ⬅️ important : marge cohérente
        }
        .frame(maxWidth: .infinity) // ⬅️ crucial : permet à tout de s'étirer correctement
    }
}


// Carte pour une suggestion de repas individuelle
struct MealSuggestionCard: View {
    let suggestion: AIMeal
    let isSelected: Bool
    let onToggle: (Bool) -> Void

    @State private var localIsSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)

                    Text(suggestion.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                Spacer()

                // Bouton de sélection (checkbox)
                Button(action: {
                    localIsSelected.toggle()
                    onToggle(!isSelected)
                }) {
                    Image(systemName: localIsSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(localIsSelected ? .blue : .gray)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(localIsSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
        .onAppear {
            localIsSelected = isSelected
        }
        .onChange(of: isSelected) { newValue in
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
