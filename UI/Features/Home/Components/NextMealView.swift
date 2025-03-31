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
    @State private var filteredRecipes: [DetailedRecipe] = []
    @State private var isLoading = false
    @State private var isExpanded = false
    @State private var currentIndex = 0
    @State private var showingRecipeDetail = false
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if filteredRecipes.isEmpty {
                emptyView
            } else {
                // Carousel de recettes
                VStack(spacing: 8) {
                    // Carousel principal
                    TabView(selection: $currentIndex) {
                        ForEach(Array(filteredRecipes.enumerated()), id: \.element.id) { index, recipe in
                            recipeCard(for: recipe, index: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: isExpanded ? 180 : 100)
                    
                    // Indicateur de pagination
                    if filteredRecipes.count > 1 {
                        HStack(spacing: 6) {
                            ForEach(0..<filteredRecipes.count, id: \.self) { index in
                                Circle()
                                    .fill(currentIndex == index ? Color.white : Color.gray.opacity(0.5))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
                .animation(.spring(), value: isExpanded)
            }
        }
        .onAppear {
            print("NextMealView apparaît - chargement des recettes...")
            Task {
                await loadSavedRecipes()
            }
        }
        .sheet(isPresented: $showingRecipeDetail) {
            if !filteredRecipes.isEmpty && currentIndex < filteredRecipes.count {
                NavigationView {
                    SingleRecipeDetailView(recipe: filteredRecipes[currentIndex])
                        .navigationTitle("Détails de la recette")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Fermer") {
                                    showingRecipeDetail = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    // Carte pour une recette individuelle
    private func recipeCard(for recipe: DetailedRecipe, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // En-tête avec type de repas et heure
            HStack {
                Text(getMealTypeDisplayName(type: recipe.type))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
//                Text("•")
//                    .foregroundColor(.gray)
//                
//                Text(getCurrentTimeFormatted())
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
                
                Spacer()
                
                // Badge de calories
                Text("\(Int(recipe.nutritionFacts.calories)) kcal")
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(20)
                
                // Indicateur d'expansion
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.leading, 4)
            }
            
            // Nom de la recette
            Text(recipe.name)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
            Text(recipe.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
                .padding(.top, 4)
            
            // Section développée si isExpanded = true
            if isExpanded {

                
                // Toutes les valeurs nutritionnelles
                HStack(spacing: 16) {
                    Label {
                        Text("\(Int(recipe.nutritionFacts.proteins))g")
                            .foregroundColor(.purple)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "p.circle")
                            .foregroundColor(.purple)
                    }
                    Label {
                        Text("\(Int(recipe.nutritionFacts.fats))g")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "g.circle")
                            .foregroundColor(.yellow)
                    }
                    Label {
                        Text("\(Int(recipe.nutritionFacts.carbs))g")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "l.circle")
                            .foregroundColor(.red)
                    }
                    Label {
                        Text("\(Int(recipe.nutritionFacts.fiber))g")
                            .foregroundColor(.green)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "f.circle")
                            .foregroundColor(.green)
                    }
                }
                .padding(.top, 4)
                
                // Bouton pour voir les détails
                HStack {
                    Spacer()
                    Button(action: {
                        showingRecipeDetail = true
                    }) {
                        Text("Recette")
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .overlay( /// apply a rounded border
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.gray)
                            )
                            
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    // Vue vide quand aucune recette n'est sauvegardée
    private var emptyView: some View {
        NavigationLink(destination: PlanningView()) {
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    Text("Planifiez votre premier repas")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Charger les recettes sauvegardées
    private func loadSavedRecipes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let recipes: [DetailedRecipe] = try await localDataManager.load(forKey: "saved_detailed_recipes") {
                await MainActor.run {
                    savedRecipes = recipes
                    // Filtrer les recettes par type approprié pour le moment de la journée
                    filterRecipesForCurrentTime()
                }
            } else {
                await MainActor.run {
                    savedRecipes = []
                    filteredRecipes = []
                }
            }
        } catch {
            print("❌ Erreur lors du chargement des recettes: \(error)")
            await MainActor.run {
                savedRecipes = []
                filteredRecipes = []
            }
        }
    }
    
    // Filtrer les recettes selon l'heure actuelle
    private func filterRecipesForCurrentTime() {
        let recommendedType = getRecommendedMealType()
        
        // D'abord, essayer de trouver des recettes du type recommandé
        var filtered = savedRecipes.filter { standardizeMealType($0.type) == recommendedType }
        
        // Si aucune recette du type recommandé n'est trouvée, prendre toutes les recettes
        if filtered.isEmpty {
            filtered = savedRecipes
        }
        
        // Mettre à jour les recettes filtrées et réinitialiser l'index
        filteredRecipes = filtered
        currentIndex = 0
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
    

}

