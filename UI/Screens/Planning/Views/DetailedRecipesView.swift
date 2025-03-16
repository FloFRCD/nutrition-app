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
    @EnvironmentObject private var localDataManager: LocalDataManager  // Ajouter cette ligne
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Obtention des détails...")
                } else if !viewModel.detailedRecipes.isEmpty {
                    List {
                        ForEach(viewModel.detailedRecipes) { recipe in
                            NavigationLink(destination: SingleRecipeDetailView(recipe: recipe)) {
                                VStack(alignment: .leading) {
                                    Text(recipe.name)
                                        .font(.headline)
                                    Text(recipe.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } else if viewModel.error != nil {
                    VStack {
                        Text("Erreur lors de la récupération des détails")
                        Button("Réessayer") {
                            Task {
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
                        }
                    }
                } else {
                    Text("Aucun détail disponible")
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
        }
    }
}

struct SingleRecipeDetailView: View {
    let recipe: DetailedRecipe
    
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
            }
            .padding()
        }
        .navigationTitle(recipe.name)
    }
    
    func formatQuantity(_ value: Double) -> String {
        return value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
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
