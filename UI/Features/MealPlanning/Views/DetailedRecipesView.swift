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
    @State private var numberOfServings: Int = 1
    let recipe: DetailedRecipe

    
    var body: some View {
        NavigationView {
            ZStack {
                mainContent
                if isAutoSaving {
                    savingOverlay
                }
            }
            .navigationTitle("Détails des recettes")
            .toolbar {
                Button("Fermer") {
                    isAutoSaving = false // 👈 modif d'état
                    onDismiss()          // 👈 dismiss
                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Enregistrer") {
//                        saveRecipeWithNewServings()
//                    }
//                }
            }
            .onChange(of: numberOfServings) {
                print("🌀 Nombre de personnes modifié : \(numberOfServings)")
                if !viewModel.detailedRecipes.isEmpty {
                    Task {
                        print("🧠 Appel à autoSaveRecipes()")
                        await autoSaveRecipes()
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
            print("📥 Nouveaux détails reçus : \(newRecipes.count) recettes")
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
        if viewModel.detailedRecipes.isEmpty {
            return
        }

        await MainActor.run {
            isAutoSaving = true
        }

        do {
            // Charger les recettes existantes
            var existingRecipes: [DetailedRecipe] = []
            if let savedRecipes: [DetailedRecipe] = try? await localDataManager.load(forKey: "saved_detailed_recipes") {
                existingRecipes = savedRecipes
            }

            // Créer des copies avec les quantités ajustées
            let adjustedRecipes = viewModel.detailedRecipes.map { original in
                var adjusted = original
                adjusted.numberOfServings = numberOfServings
                adjusted.ingredients = original.ingredients.map { ingredient in
                    var adjustedIngredient = ingredient
                    adjustedIngredient.quantity *= Double(numberOfServings)
                    return adjustedIngredient
                }
                return adjusted
            }


            // Ajouter les nouvelles recettes (sans doublons)
            var updatedRecipes = existingRecipes
            var newRecipesCount = 0

            for recipe in adjustedRecipes {
                if !updatedRecipes.contains(where: { $0.name == recipe.name }) {
                    updatedRecipes.append(recipe)
                    newRecipesCount += 1
                }
            }
            
            // Sauvegarde
            try await localDataManager.save(updatedRecipes, forKey: "saved_detailed_recipes")
            print("✅ Sauvegarde : \(newRecipesCount) nouvelles recettes ajustées pour \(numberOfServings) personne(s)")

            NotificationCenter.default.post(name: Notification.Name("RecipeDeleted"), object: nil)

            try await Task.sleep(nanoseconds: 800_000_000)

            await MainActor.run {
                isAutoSaving = false
                autoSaveComplete = true
            }

        } catch {
            print("❌ Erreur lors de la sauvegarde : \(error)")
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
    @State private var isSelected = false
    @State private var numberOfServings: Int = 1


    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // En-tête avec titre et bouton de sélection
                HStack {
                    Text(recipe.name)
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    // Bouton de sélection (cœur)
                    Button(action: {
                        toggleSelection()
                    }) {
                        Image(systemName: isSelected ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(isSelected ? .red : .gray)
                    }
                }
                
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
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nombre de parts")
                        .font(.headline)

                    Stepper(value: $numberOfServings, in: 1...10) {
                        Text("\(numberOfServings) part\(numberOfServings > 1 ? "s" : "")")
                    }
                    .onChange(of: numberOfServings) {
                        updateRecipeServings()
                    }
                }
                .padding(.vertical)

                
                // Ingredients
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingrédients")
                        .font(.headline)
                    
                    ForEach(adjustedIngredients) { ingredient in
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
                
                // Bouton de suppression
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
                        }
                        Text(isDeleting ? "Suppression en cours..." : "Supprimer cette recette")
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
        .onAppear {
            numberOfServings = recipe.numberOfServings

            Task {
                isSelected = await localDataManager.isRecipeSelected(recipe)
            }
        }
    }
    
    func formatQuantity(_ value: Double) -> String {
        return value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
    
    private var adjustedIngredients: [DetailedRecipe.Ingredient] {
        recipe.ingredients.map { original in
            var adjusted = original
            adjusted.quantity = original.quantity / Double(recipe.numberOfServings) * Double(numberOfServings)
            return adjusted
        }
    }
    
    // Basculer la sélection de cette recette
    private func toggleSelection() {
        Task {
            await localDataManager.toggleRecipeSelection(recipe)
            isSelected = await localDataManager.isRecipeSelected(recipe)
            
            // Notifier le changement pour mettre à jour d'autres vues
            NotificationCenter.default.post(name: NSNotification.Name("RecipeSelectionChanged"), object: nil)
        }
    }
    
    // Fonction pour supprimer la recette
    private func deleteRecipeAndNotify() {
        // Activer l'indicateur de suppression
        isDeleting = true
        
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
                
                // Supprimer la recette actuelle
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
                
                // Revenir à l'écran précédent
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("❌ Erreur lors de la suppression de la recette: \(error)")
                await MainActor.run {
                    isDeleting = false
                }
            }
        }
    }
    
    private func updateRecipeServings() {
        Task {
            await localDataManager.updateRecipe(recipe.name) { old in
                var copy = old
                copy.numberOfServings = numberOfServings
                copy.ingredients = old.ingredients.map { ing in
                    var updated = ing
                    updated.quantity = ing.quantity / Double(old.numberOfServings) * Double(numberOfServings)
                    return updated
                }
                return copy
            }
            print("🔄 Recette '\(recipe.name)' mise à jour pour \(numberOfServings) pers.")
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
