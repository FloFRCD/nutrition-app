//
//  RecipeSelectionForJournalView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import Foundation
import SwiftUI

struct RecipeSelectionForJournalView: View {
    let mealType: MealType
    let onRecipeSelected: (DetailedRecipe, Double) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var localDataManager: LocalDataManager
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var savedRecipes: [DetailedRecipe] = []
    @State private var selectedRecipe: DetailedRecipe?
    @State private var servingSize: String = "1"
    
    var filteredRecipes: [DetailedRecipe] {
        if searchText.isEmpty {
            return savedRecipes
        } else {
            return savedRecipes.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedRecipe != nil {
                    // Détails de la recette sélectionnée
                    recipeDetailView
                } else {
                    // Liste des recettes disponibles
                    recipeListView
                }
            }
            .navigationTitle("Choisir une recette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                if selectedRecipe != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Retour") {
                            selectedRecipe = nil
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await loadSavedRecipes()
                }
            }
        }
    }
    // Vue de la liste des recettes
    private var recipeListView: some View {
        VStack {
            // Barre de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Rechercher une recette", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            if isLoading {
                Spacer()
                ProgressView("Chargement des recettes...")
                Spacer()
            } else if savedRecipes.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "heart")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Aucune recette sauvegardée")
                        .font(.headline)
                    
                    Text("Ajoutez des recettes à vos favoris pour les ajouter à votre journal")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else {
                List {
                    ForEach(groupedRecipesByMealType, id: \.key) { mealType, recipes in
                        Section(header: Text(mealType)) {
                            ForEach(recipes) { recipe in
                                Button {
                                    selectedRecipe = recipe
                                } label: {
                                    RecipeRowForJournal(recipe: recipe)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    // Vue des détails de la recette sélectionnée
    private var recipeDetailView: some View {
        guard let recipe = selectedRecipe else { return AnyView(EmptyView()) }
        
        return AnyView(
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Titre et description
                    Text(recipe.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(recipe.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Valeurs nutritionnelles
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Valeurs nutritionnelles")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            NutritionInfoCard(
                                title: "Calories",
                                value: "\(recipe.nutritionFacts.calories)",
                                unit: "kcal"
                            )
                            
                            NutritionInfoCard(
                                title: "Protéines",
                                value: "\(Int(recipe.nutritionFacts.proteins))",
                                unit: "g"
                            )
                            
                            NutritionInfoCard(
                                title: "Glucides",
                                value: "\(Int(recipe.nutritionFacts.carbs))",
                                unit: "g"
                            )
                            
                            NutritionInfoCard(
                                title: "Lipides",
                                value: "\(Int(recipe.nutritionFacts.fats))",
                                unit: "g"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Nombre de portions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre de portions")
                            .font(.headline)
                        
                        HStack {
                            TextField("Portions", text: $servingSize)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                            
                            Stepper("", value: Binding(
                                get: { Double(servingSize) ?? 1 },
                                set: { servingSize = String(max(0.5, $0)) }
                            ), step: 0.5)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Bouton d'ajout
                    Button {
                        if let servings = Double(servingSize), servings > 0 {
                            onRecipeSelected(recipe, servings)
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("Ajouter au journal")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(Double(servingSize) == nil || Double(servingSize)! <= 0)
                    .padding(.top)
                }
                .padding()
            }
        )
    }
    
    private func loadSavedRecipes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Utiliser la même méthode que dans SavedRecipesView avec la même clé
            if let recipes: [DetailedRecipe] = try await localDataManager.load(forKey: "saved_detailed_recipes") {
                await MainActor.run {
                    savedRecipes = recipes
                    print("📋 Chargé \(recipes.count) recettes sauvegardées")
                }
            } else {
                await MainActor.run {
                    savedRecipes = []
                    print("📋 Aucune recette sauvegardée trouvée")
                }
            }
        } catch {
            print("❌ Erreur lors du chargement des recettes: \(error)")
            await MainActor.run {
                savedRecipes = []
            }
        }
    }
    
    private var groupedRecipesByMealType: [(key: String, values: [DetailedRecipe])] {
        // Standardiser et grouper les types de repas
        var groupedRecipes: [String: [DetailedRecipe]] = [:]
        
        // Définir les catégories standards
        let mealTypeCategories = ["Petit-déjeuner", "Déjeuner", "Dîner", "Collation"]
        
        // Initialiser les groupes vides
        for category in mealTypeCategories {
            groupedRecipes[category] = []
        }
        
        // Classifier chaque recette
        for recipe in filteredRecipes {
            let category = standardizeMealType(recipe.type)
            groupedRecipes[category, default: []].append(recipe)
        }
        
        // Filtrer les groupes vides et trier
            let filteredDict = groupedRecipes.filter { !$0.value.isEmpty }
            let sortedArray = filteredDict.map { (key: $0.key, values: $0.value) }
                .sorted { pair1, pair2 in
                    let mealOrder = ["Petit-déjeuner": 0, "Déjeuner": 1, "Dîner": 2, "Collation": 3, "Déjeuner/Dîner": 4]
                    return (mealOrder[pair1.key] ?? 999) < (mealOrder[pair2.key] ?? 999)
                }
            return sortedArray
    }
    
    // Standardiser les types de repas
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

struct RecipeRowForJournal: View {
    let recipe: DetailedRecipe
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                
                Text(recipe.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(recipe.nutritionFacts.calories) kcal")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                HStack(spacing: 5) {
                    Text("P:\(Int(recipe.nutritionFacts.proteins))g")
                    Text("G:\(Int(recipe.nutritionFacts.carbs))g")
                    Text("L:\(Int(recipe.nutritionFacts.fats))g")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct NutritionInfoCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}
