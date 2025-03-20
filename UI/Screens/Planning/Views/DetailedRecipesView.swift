//
//  DetailedRecipeView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 16/03/2025.
//

import Foundation
import SwiftUI


struct DetailedRecipesView: View {
    let recipes: [AIMeal]
    let onDismiss: () -> Void
    @StateObject private var viewModel = DetailedRecipesViewModel()
    @EnvironmentObject private var localDataManager: LocalDataManager
    @State private var isAutoSaving = false
    @State private var autoSaveComplete = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Contenu principal
                mainContent
                
                // Overlay de sauvegarde automatique
                if isAutoSaving {
                    savingOverlay
                }
            }
            .navigationTitle("Détails des recettes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadRecipeDetails()
            }
        }
        // Utilisez onReceive pour surveiller les changements dans detailedRecipes
        .onReceive(viewModel.$detailedRecipes) { newRecipes in
            if !newRecipes.isEmpty && !autoSaveComplete && !isAutoSaving {
                Task {
                    await autoSaveRecipes()
                }
            }
        }
    }
    
    // Contenu principal décomposé en une propriété calculée
    private var mainContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Obtention des détails...")
            } else if !viewModel.detailedRecipes.isEmpty {
                recipesList
            } else if viewModel.error != nil {
                errorView
            } else {
                Text("Aucun détail disponible")
            }
        }
    }
    
    // La liste des recettes
    private var recipesList: some View {
        List {
            // Message de confirmation de sauvegarde
            if autoSaveComplete {
                saveConfirmationRow
            }
            
            // Liste des recettes
            ForEach(viewModel.detailedRecipes) { recipe in
                recipeRow(for: recipe)
            }
        }
    }
    
    // Message de confirmation de sauvegarde
    private var saveConfirmationRow: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Recettes automatiquement sauvegardées")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .listRowBackground(Color(.secondarySystemBackground))
        .padding(.vertical, 8)
    }
    
    // Ligne pour une recette spécifique
    private func recipeRow(for recipe: DetailedRecipe) -> some View {
        NavigationLink(
            destination: recipeDetailView(for: recipe)
        ) {
            SavedRecipeCard(recipe: recipe)
        }
    }
    
    // Vue de détail d'une recette
    private func recipeDetailView(for recipe: DetailedRecipe) -> some View {
        SingleRecipeDetailView(recipe: recipe)
            .environmentObject(localDataManager)
    }
    
    // Vue d'erreur
    private var errorView: some View {
        VStack {
            Text("Erreur lors de la récupération des détails")
            Button("Réessayer") {
                Task {
                    await loadRecipeDetails()
                }
            }
        }
    }
    
    // Overlay pendant la sauvegarde
    private var savingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Sauvegarde automatique en cours...")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(.systemGray5).opacity(0.8))
            .cornerRadius(10)
        }
    }
    
    // Chargement des détails des recettes
    private func loadRecipeDetails() async {
        if let userProfile = localDataManager.userProfile {
            await viewModel.fetchRecipeDetails(
                for: recipes,
                userProfile: userProfile
            )
        } else {
            await viewModel.fetchRecipeDetails(
                for: recipes,
                userProfile: UserProfile.default
            )
        }
    }
    
    // Fonction pour sauvegarder automatiquement les recettes
    private func autoSaveRecipes() async {
        // Ne rien faire si les recettes sont vides
        if viewModel.detailedRecipes.isEmpty {
            return
        }
        
        // Afficher l'indicateur de sauvegarde
        await MainActor.run {
            isAutoSaving = true
        }
        
        do {
            // Récupérer les recettes existantes
            var existingRecipes: [DetailedRecipe] = []
            if let savedRecipes: [DetailedRecipe] = try? await localDataManager.load(forKey: "saved_detailed_recipes") {
                existingRecipes = savedRecipes
            }
            
            // Ajouter les nouvelles recettes en évitant les doublons
            var updatedRecipes = existingRecipes
            var newRecipesCount = 0
            
            for recipe in viewModel.detailedRecipes {
                // Vérifier si la recette n'existe pas déjà par son nom
                if !updatedRecipes.contains(where: { $0.name == recipe.name }) {
                    updatedRecipes.append(recipe)
                    newRecipesCount += 1
                }
            }
            
            // Sauvegarder la liste mise à jour
            try await localDataManager.save(updatedRecipes, forKey: "saved_detailed_recipes")
            print("✅ Sauvegarde automatique: \(newRecipesCount) nouvelles recettes sauvegardées (total: \(updatedRecipes.count))")
            
            // Notifier que des recettes ont été sauvegardées pour rafraîchir les autres vues
            NotificationCenter.default.post(name: Notification.Name("RecipeDeleted"), object: nil)
            
            // Ajouter un petit délai pour que l'utilisateur voit le processus
            try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconde
            
            // Cacher l'indicateur de sauvegarde et indiquer que la sauvegarde est terminée
            await MainActor.run {
                isAutoSaving = false
                autoSaveComplete = true
            }
        } catch {
            print("❌ Erreur lors de la sauvegarde automatique: \(error)")
            await MainActor.run {
                isAutoSaving = false
            }
        }
    }
}

struct SingleRecipeDetailView: View {
    let recipe: DetailedRecipe
    @EnvironmentObject private var localDataManager: LocalDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(recipe.name)
                    .font(.title)
                    .bold()
                
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Nutrition facts
                VStack(alignment: .leading, spacing: 10) {
                    Text("Valeurs nutritionnelles")
                        .font(.headline)
                    
                    HStack {
                        NutritionFactBox(title: "Calories", value: "\(recipe.nutritionFacts.calories)", unit: "kcal")
                        Spacer()
                        NutritionFactBox(title: "Protéines", value: String(format: "%.1f", recipe.nutritionFacts.proteins), unit: "g")
                        Spacer()
                        NutritionFactBox(title: "Glucides", value: String(format: "%.1f", recipe.nutritionFacts.carbs), unit: "g")
                    }
                    
                    HStack {
                        NutritionFactBox(title: "Lipides", value: String(format: "%.1f", recipe.nutritionFacts.fats), unit: "g")
                        Spacer()
                        NutritionFactBox(title: "Fibres", value: String(format: "%.1f", recipe.nutritionFacts.fiber), unit: "g")
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                // Ingredients
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingrédients")
                        .font(.headline)
                    
                    ForEach(recipe.ingredients) { ingredient in
                        HStack {
                            Text("•")
                            Text("\(formatQuantity(ingredient.quantity)) \(ingredient.unit) \(ingredient.name)")
                        }
                    }
                }
                
                // Instructions
                if !recipe.instructions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Préparation")
                            .font(.headline)
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .font(.subheadline)
                                    .bold()
                                Text(step)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Bouton de suppression (plus visible)
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        if isDeleting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        } else {
                            Image(systemName: "trash")
                                .font(.headline)
                        }
                        Text(isDeleting ? "Suppression en cours..." : "Supprimer cette recette")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isDeleting ? Color.gray : Color.red)
                    .cornerRadius(10)
                }
                .disabled(isDeleting)
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .alert("Supprimer cette recette ?", isPresented: $showingDeleteConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                deleteRecipeAndNotify()
            }
        } message: {
            Text("Cette recette sera définitivement supprimée de vos recettes sélectionnées.")
        }
    }
    
    func formatQuantity(_ value: Double) -> String {
        return value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
    
    // Fonction améliorée pour supprimer la recette
    private func deleteRecipeAndNotify() {
        isDeleting = true
        
        Task {
            do {
                // Approche plus directe: récupérer les recettes, filtrer par nom
                let recipes: [DetailedRecipe]? = try? await localDataManager.load(forKey: "saved_detailed_recipes")
                var updatedRecipes = recipes ?? []
                
                // Afficher les noms des recettes avant suppression pour le débogage
                print("Recettes avant suppression:")
                for (index, r) in updatedRecipes.enumerated() {
                    print("[\(index)] \(r.name) - ID: \(r.id)")
                }
                
                // Compter combien de recettes nous avions
                let countBefore = updatedRecipes.count
                
                // Méthode alternative: filtrer par nom au lieu de l'ID
                updatedRecipes = updatedRecipes.filter { $0.name != recipe.name }
                
                // Compter combien nous en avons maintenant
                let countAfter = updatedRecipes.count
                print("Recettes supprimées: \(countBefore - countAfter)")
                
                // Sauvegarder la liste mise à jour
                try await localDataManager.save(updatedRecipes, forKey: "saved_detailed_recipes")
                
                // Attendre un peu plus longtemps
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                
                // Notifier et retourner
                NotificationCenter.default.post(name: NSNotification.Name("RecipeDeleted"), object: nil)
                
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("Erreur lors de la suppression: \(error)")
                await MainActor.run {
                    isDeleting = false
                }
            }
        }
    }
}

// Ajoutez cette extension à la fin de votre fichier
extension NSNotification.Name {
    static let recipeDeleted = NSNotification.Name("RecipeDeleted")
}

struct NutritionFactBox: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 80)
    }
}
