//
//  SelectedRecipesView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/03/2025.
//

import Foundation
import SwiftUI


struct SelectedRecipesView: View {
    @EnvironmentObject private var localDataManager: LocalDataManager
    @State private var selectedRecipes: [DetailedRecipe] = []
    @State private var isLoading = false
    @State private var refreshID = UUID()
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if selectedRecipes.isEmpty {
                ContentUnavailableView(
                    "Aucune recette sélectionnée",
                    systemImage: "heart",
                    description: Text("Ajoutez des recettes à vos sélections en utilisant le bouton ♥")
                )
            } else {
                VStack(spacing: 20) {
                    // Afficher les recettes sélectionnées par type
                    let mealOrder = ["Petit-déjeuner", "Déjeuner", "Collation", "Dîner"]

                    ForEach(mealOrder, id: \.self) { mealType in
                        if let recipes = groupedRecipesByMealType[mealType], !recipes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                // En-tête de section
                                Text(mealType)
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                // Recettes de ce type
                                ForEach(recipes) { recipe in
                                    NavigationLink {
                                        SingleRecipeDetailView(recipe: recipe)
                                            .environmentObject(localDataManager) // ✅ injection ici
                                    } label: {
                                        SavedRecipeCard(recipe: recipe)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
                .id(refreshID) // Force refresh quand refreshID change
            }
        }
        .onAppear {
            Task {
                await loadSelectedRecipes()
            }
        }
        .refreshable {
            await loadSelectedRecipes()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RecipeSelectionChanged"))) { _ in
            // Recharger les recettes sélectionnées quand une notification est reçue
            Task {
                await loadSelectedRecipes()
            }
        }
    }
    
    // Grouper les recettes par type de repas standardisé
    var groupedRecipesByMealType: [String: [DetailedRecipe]] {
        var groupedRecipes: [String: [DetailedRecipe]] = [:]
        
        // Définir les catégories standards
        let mealTypeCategories = ["Petit-déjeuner", "Déjeuner", "Dîner", "Collation"]
        
        // Initialiser les groupes vides
        for category in mealTypeCategories {
            groupedRecipes[category] = []
        }
        
        // Classifier chaque recette
        for recipe in selectedRecipes {
            let category = standardizeMealType(recipe.type)
            groupedRecipes[category, default: []].append(recipe)
        }
        
        return groupedRecipes
    }
    
    // Charger les recettes sélectionnées
    private func loadSelectedRecipes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let recipes = try await localDataManager.loadSelectedRecipes()
            await MainActor.run {
                selectedRecipes = recipes
                print("✅ Chargé \(recipes.count) recettes sélectionnées")
                refreshID = UUID()
            }
        } catch {
            print("❌ Erreur lors du chargement des recettes sélectionnées: \(error)")
            await MainActor.run {
                selectedRecipes = []
            }
        }
    }
    
    // Standardiser les types de repas pour regroupement
    private func standardizeMealType(_ type: String) -> String {
        let lowerType = type.lowercased()
        
        if lowerType.contains("petit") || lowerType.contains("breakfast") || lowerType.contains("matin") {
            return "Petit-déjeuner"
        } else if lowerType.contains("lunch") || lowerType.contains("déjeuner") || lowerType.contains("midi") {
            return "Déjeuner"
        } else if lowerType.contains("dinner") || lowerType.contains("dîner") || lowerType.contains("soir") {
            return "Dîner"
        } else if lowerType.contains("snack") || lowerType.contains("collation") || lowerType.contains("encas") {
            return "Collation"
        }
        
        return "Déjeuner/Dîner" // Par défaut
    }
}
