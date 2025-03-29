//
//  RecipeSelectionView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import SwiftUI

import SwiftUI

struct RecipeSelectionView: View {
    let mealType: MealType
    let onRecipeSelected: (Recipe) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var searchText = ""
    @EnvironmentObject private var localDataManager: LocalDataManager
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            // Vérifiez si savedRecipes est nil et fournissez un tableau vide comme valeur par défaut
            return localDataManager.savedRecipes ?? []
        } else {
            // Filtrez les recettes de manière sécurisée
            return (localDataManager.savedRecipes ?? []).filter { recipe in
                recipe.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
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
                
                if filteredRecipes.isEmpty {
                    // Aucune recette
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Aucune recette trouvée")
                            .font(.headline)
                        
                        Text("Essayez d'ajouter des recettes ou \nde modifier votre recherche")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                } else {
                    // Liste des recettes
                    List {
                        ForEach(filteredRecipes) { recipe in
                            Button(action: {
                                onRecipeSelected(recipe)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                RecipeRow(recipe: recipe)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Sélectionner une recette")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    
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
            
            if let nutrition = recipe.nutritionValues {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(nutrition.calories)) kcal")
                        .font(.subheadline)
                        .bold()
                    
                    HStack(spacing: 4) {
                        Text("P:\(Int(nutrition.proteins))g")
                        Text("G:\(Int(nutrition.carbohydrates))g")
                        Text("L:\(Int(nutrition.fats))g")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
