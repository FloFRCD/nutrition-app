//
//  NextMealView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct NextMealView: View {
    @EnvironmentObject private var localDataManager: LocalDataManager
    @State private var savedRecipes: [DetailedRecipe] = []
    @State private var isLoading = false
    @State private var isExpanded = false
    @State private var nextMealRecipe: DetailedRecipe?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prochain repas")
                .font(.headline)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if nextMealRecipe != nil {
                // Vue avec recette
                filledView
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
            } else if !savedRecipes.isEmpty {
                // Des recettes existent mais aucune n'est appropriée pour ce moment de la journée
                alternativeFilledView
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
            } else {
                // Aucune recette sauvegardée
                emptyView
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .onAppear {
            Task {
                await loadSavedRecipes()
            }
        }
    }
    
    // Vue quand une recette est disponible pour le prochain repas
    private var filledView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let recipe = nextMealRecipe {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(getMealTypeDisplayName(type: recipe.type))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(getCurrentTimeFormatted())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(recipe.name)
                            .font(.system(size: 17, weight: .semibold))
                            .lineLimit(isExpanded ? nil : 1)
                        
                        if isExpanded {
                            Text(recipe.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                            
                            // Valeurs nutritionnelles en format compact
                            HStack(spacing: 10) {
                                Label("\(Int(recipe.nutritionFacts.calories)) kcal", systemImage: "flame.fill")
                                    .font(.footnote)
                                    .foregroundColor(.orange)
                                
                                Label("\(Int(recipe.nutritionFacts.proteins))g", systemImage: "fork.knife")
                                    .font(.footnote)
                                    .foregroundColor(.purple)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // Badge calorique
                    Text("\(Int(recipe.nutritionFacts.calories)) kcal")
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                    
                    // Flèche d'expansion
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
            }
        }
    }
    
    // Vue alternative quand des recettes sont disponibles mais pas pour ce moment
    private var alternativeFilledView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recettes disponibles")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(getRecommendedMealType())
                        .font(.system(size: 17, weight: .semibold))
                }
                
                Spacer()
                
                // Flèche d'expansion
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if isExpanded && !savedRecipes.isEmpty {
                // Afficher quelques recettes du type recommandé
                let recommendedType = getRecommendedMealType()
                let filteredRecipes = savedRecipes.filter { standardizeMealType($0.type) == recommendedType }
                
                if !filteredRecipes.isEmpty {
                    ForEach(filteredRecipes.prefix(2), id: \.id) { recipe in
                        NavigationLink(destination: SingleRecipeDetailView(recipe: recipe)) {
                            HStack {
                                Text("•")
                                Text(recipe.name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(Int(recipe.nutritionFacts.calories)) kcal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    if filteredRecipes.count > 2 {
                        Text("+ \(filteredRecipes.count - 2) autres...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                    }
                } else {
                    Text("Aucune recette de \(recommendedType.lowercased()) disponible")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
    }
    
    // Vue vide quand aucune recette n'est sauvegardée
    private var emptyView: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text("Planifiez votre premier repas")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            NavigationLink(destination: PlanningView()) {
                Text("Créer un planning")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
    
    // Charger les recettes sauvegardées
    private func loadSavedRecipes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let recipes: [DetailedRecipe] = try await localDataManager.load(forKey: "saved_detailed_recipes") {
                await MainActor.run {
                    savedRecipes = recipes
                    nextMealRecipe = findNextMealRecipe()
                }
            } else {
                await MainActor.run {
                    savedRecipes = []
                    nextMealRecipe = nil
                }
            }
        } catch {
            print("❌ Erreur lors du chargement des recettes: \(error)")
            await MainActor.run {
                savedRecipes = []
                nextMealRecipe = nil
            }
        }
    }
    
    // Trouver la recette la plus appropriée pour le prochain repas
    private func findNextMealRecipe() -> DetailedRecipe? {
        // Obtenir le type de repas recommandé
        let recommendedType = getRecommendedMealType()
        
        // Filtrer les recettes par type
        let filteredRecipes = savedRecipes.filter { standardizeMealType($0.type) == recommendedType }
        
        // Si des recettes sont disponibles, renvoyer la première
        return filteredRecipes.first
    }
    
    // Déterminer le type de repas recommandé en fonction de l'heure actuelle
    private func getRecommendedMealType() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour >= 6 && hour < 10 {
            return "Petit-déjeuner"
        } else if hour >= 10 && hour < 14 {
            return "Déjeuner"
        } else if hour >= 14 && hour < 18 {
            return "Collation"
        } else if hour >= 18 && hour < 22 {
            return "Dîner"
        } else {
            return "Collation"
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
        
        return "Collation" // Par défaut
    }
    
    // Obtenir le nom d'affichage pour un type de repas
    private func getMealTypeDisplayName(type: String) -> String {
        return standardizeMealType(type)
    }
    
    // Obtenir l'heure actuelle formatée
    private func getCurrentTimeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}


