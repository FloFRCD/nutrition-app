//
//  SavedRecipesView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 16/03/2025.
//

import Foundation
import SwiftUI

struct SavedRecipesView: View {
    @EnvironmentObject private var localDataManager: LocalDataManager
    @State private var savedRecipes: [DetailedRecipe] = []
    @State private var isLoading = false
    @State private var searchText = "" // Pour la recherche des recettes
    @State private var refreshID = UUID() // Pour forcer le rafraîchissement de la vue
    @State private var recipeToDelete: DetailedRecipe?
    @State private var showingDeleteConfirmation = false
    @State private var lastUpdated = Date() // Suivi de la dernière mise à jour
 
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if savedRecipes.isEmpty {
                    ContentUnavailableView(
                        "Aucune recette sauvegardée",
                        systemImage: "bookmark",
                        description: Text("Sélectionnez des suggestions et sauvegardez-les pour les voir ici")
                    )
            } else {
                VStack(spacing: 0) {
                    // Barre de recherche
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color(.clear))

//                    // Dernière mise à jour
//                    Text("Dernière mise à jour: \(formattedDate(lastUpdated))")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .padding(.trailing)

                    LazyVStack(spacing: 16) {
                        if !searchText.isEmpty {
                            let filteredRecipes = filteredRecipesBySearch
                            if filteredRecipes.isEmpty {
                                Text("Aucun résultat pour '\(searchText)'")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 20)
                            } else {
                                recipesSection(recipes: filteredRecipes)
                            }
                        } else {
                            ForEach(groupedRecipesByMealType.keys.sorted(), id: \.self) { mealType in
                                let displayName = getMealTypeDisplayName(type: mealType)
                                if let recipes = groupedRecipesByMealType[mealType], !recipes.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(displayName)
                                            .font(.headline)
                                            .padding(.horizontal)
                                            .padding(.top, 8)

                                        recipesSection(recipes: recipes)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 100) // Pour ne pas être caché par la TabBar
                    .id(refreshID)
                }
            }
        }
        .onAppear {
            Task { await loadSavedRecipes() }
        }
        .refreshable {
            await loadSavedRecipes()
        }
        .alert("Supprimer cette recette ?", isPresented: $showingDeleteConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                if let recipe = recipeToDelete {
                    deleteRecipe(recipe)
                }
            }
        } message: {
            Text("Cette recette sera définitivement supprimée de vos recettes.")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RecipeDeleted"))) { _ in
            Task {
                await loadSavedRecipes()
                refreshID = UUID()
                lastUpdated = Date()
            }
        }
    }

    
    // Formater la date pour le débogage
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // Fonction pour afficher une section de recettes
    private func recipesSection(recipes: [DetailedRecipe]) -> some View {
        ForEach(recipes) { recipe in
            NavigationLink {
                SingleRecipeDetailView(recipe: recipe)
                    .environmentObject(localDataManager) // ✅ injection ici
            } label: {
                SavedRecipeCard(recipe: recipe)
            }

            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(role: .destructive) {
                    recipeToDelete = recipe
                    showingDeleteConfirmation = true
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
        }
    }
    
    // Barre de recherche personnalisée
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Rechercher une recette...", text: $searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.white))
        .cornerRadius(10)
    }
    
    // Filtrer les recettes par terme de recherche
    var filteredRecipesBySearch: [DetailedRecipe] {
        guard !searchText.isEmpty else { return savedRecipes }
        
        return savedRecipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(searchText) ||
            recipe.description.localizedCaseInsensitiveContains(searchText) ||
            recipe.type.localizedCaseInsensitiveContains(searchText)
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
        for recipe in savedRecipes {
            let category = standardizeMealType(recipe.type)
            groupedRecipes[category, default: []].append(recipe)
        }
        
        return groupedRecipes
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
        
        // Par défaut, considérer comme Déjeuner/Dîner
        return "Déjeuner/Dîner"
    }
    
    // Obtenir un nom d'affichage plus court pour les types de repas
    private func getMealTypeDisplayName(type: String) -> String {
        switch type {
        case "Petit-déjeuner":
            return "Petit-déjeuner"
        case "Déjeuner":
            return "Déjeuner"
        case "Dîner":
            return "Dîner"
        case "Collation":
            return "Collation"
        case "Déjeuner/Dîner":
            return "Déjeuner/Dîner"
        default:
            return type
        }
    }
    
    // Charger les recettes sauvegardées - avec journalisation améliorée
    func loadSavedRecipes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let recipes: [DetailedRecipe] = try await localDataManager.load(forKey: "saved_detailed_recipes") {
                await MainActor.run {
                    savedRecipes = recipes
                    print("📋 Chargé \(recipes.count) recettes sauvegardées")
                    
                    // Actualiser l'horodatage
                    lastUpdated = Date()
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
    
    // Supprimer une recette (depuis le menu contextuel)
    func deleteRecipe(_ recipeToDelete: DetailedRecipe) {
        // Supprimer du tableau local
        savedRecipes.removeAll { $0.id == recipeToDelete.id }
        
        // Rafraîchir l'interface
        refreshID = UUID()
        
        // Sauvegarder les modifications
        Task {
            do {
                try await localDataManager.save(savedRecipes, forKey: "saved_detailed_recipes")
                print("✅ Recette supprimée et modifications sauvegardées")
                lastUpdated = Date()
            } catch {
                print("❌ Erreur lors de la sauvegarde après suppression: \(error)")
                // Recharger en cas d'erreur pour garantir la cohérence
                await loadSavedRecipes()
            }
        }
    }
}

struct SavedRecipeCard: View {
    let recipe: DetailedRecipe
    @EnvironmentObject private var localDataManager: LocalDataManager
    @State private var isSelected = false
    @State private var showDeleteConfirmation = false
  
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(recipe.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Indicateur de sélection
                if isSelected {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.leading, 4)
                }
                
                // Badge pour le type de repas
                Text(getShortMealTypeDisplayName(type: recipe.type))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getMealTypeColor(type: recipe.type))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Informations nutritionnelles dans une ligne horizontale
            HStack(spacing: 10) {
                NutritionInfoTag(value: "\(Int(recipe.nutritionFacts.calories))", unit: "Cal")
                NutritionInfoTag(value: "\(Int(recipe.nutritionFacts.proteins))", unit: "g Prot")
                NutritionInfoTag(value: "\(Int(recipe.nutritionFacts.carbs))", unit: "g Carb")
                NutritionInfoTag(value: "\(Int(recipe.nutritionFacts.fats))", unit: "g Lip")
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
        .contextMenu {
            Button(action: {
                toggleSelection()
            }) {
                Label(
                    isSelected ? "Retirer des sélections" : "Ajouter aux sélections",
                    systemImage: isSelected ? "heart.slash" : "heart"
                )
            }
            
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
        .onAppear {
            // Vérifier si la recette est sélectionnée au chargement
            Task {
                isSelected = await localDataManager.isRecipeSelected(recipe)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RecipeSelectionChanged"))) { _ in
            // Mettre à jour l'état de sélection quand une notification est reçue
            Task {
                isSelected = await localDataManager.isRecipeSelected(recipe)
            }
        }
        .alert("Supprimer cette recette ?", isPresented: $showDeleteConfirmation) {
                    Button("Annuler", role: .cancel) { }
                    Button("Supprimer", role: .destructive) {
                        deleteRecipe()
                    }
                } message: {
                    Text("Cette recette sera définitivement supprimée de vos recettes enregistrées.")
                }
    }
    
    // Fonction pour obtenir un nom très court d'affichage du type de repas
    private func getShortMealTypeDisplayName(type: String) -> String {
        let lowerType = type.lowercased()
        if lowerType.contains("petit") || lowerType.contains("breakfast") {
            return "P. déjeuner"
        } else if lowerType.contains("lunch") || lowerType.contains("déjeuner") {
            return "Déjeuner"
        } else if lowerType.contains("dinner") || lowerType.contains("dîner") {
            return "Dîner"
        } else if lowerType.contains("snack") || lowerType.contains("collation") {
            return "Collation"
        }
        return type
    }
    
    // Fonction pour supprimer la recette (en utilisant la même logique que SingleRecipeDetailView)
        private func deleteRecipe() {
            Task {
                do {
                    // Vérifier si le fichier de stockage existe et le lire
                    var savedRecipes: [DetailedRecipe] = []
                    if let loadedRecipes: [DetailedRecipe] = try? await localDataManager.load(forKey: "saved_detailed_recipes") {
                        savedRecipes = loadedRecipes
                    }
                    
                    // Le nombre de recettes avant suppression
                    let initialCount = savedRecipes.count
                    print("📝 Avant suppression: \(initialCount) recettes")
                    
                    // Supprimer la recette actuelle par son nom (comme dans SingleRecipeDetailView)
                    savedRecipes.removeAll { $0.name == recipe.name }
                    
                    // Vérifier si la suppression a fonctionné
                    let finalCount = savedRecipes.count
                    print("📝 Après suppression: \(finalCount) recettes (supprimé: \(initialCount - finalCount))")
                    
                    // Sauvegarder la liste mise à jour
                    try await localDataManager.save(savedRecipes, forKey: "saved_detailed_recipes")
                    print("✅ Recette supprimée avec succès et stockage mis à jour")
                    
                    // Si la recette était dans les sélections, la retirer aussi
                    await localDataManager.removeFromSelection(recipe)
                    
                    // Ajouter un délai pour montrer le feedback de suppression
                    try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconde
                    
                    // Poster une notification pour informer les autres vues
                    NotificationCenter.default.post(
                        name: NSNotification.Name("RecipeDeleted"),
                        object: recipe.id
                    )
                    print("📣 Notification de suppression envoyée")
                    
                } catch {
                    print("❌ Erreur lors de la suppression de la recette: \(error)")
                }
            }
        }
    
    // Fonction pour obtenir la couleur en fonction du type de repas
    private func getMealTypeColor(type: String) -> Color {
        let lowerType = type.lowercased()
        if lowerType.contains("petit") || lowerType.contains("breakfast") {
            return Color.orange
        } else if lowerType.contains("lunch") || lowerType.contains("déjeuner") {
            return Color.green
        } else if lowerType.contains("dinner") || lowerType.contains("dîner") {
            return Color.blue
        } else if lowerType.contains("snack") || lowerType.contains("collation") {
            return Color.purple
        }
        return Color.gray
    }
    
    // Basculer la sélection
    private func toggleSelection() {
        Task {
            await localDataManager.toggleRecipeSelection(recipe)
            isSelected = await localDataManager.isRecipeSelected(recipe)
            
            // Notifier le changement
            NotificationCenter.default.post(name: NSNotification.Name("RecipeSelectionChanged"), object: nil)
        }
    }
}

// Composant pour afficher les informations nutritionnelles
struct NutritionInfoTag: View {
    let value: String
    let unit: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}
