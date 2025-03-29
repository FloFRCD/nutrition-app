//
//  MealSectionView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import SwiftUI

struct MealSectionView: View {
    var mealType: MealType
    var entries: [FoodEntry]
    var targetCalories: Int
    var onAddPhoto: () -> Void
    var barcode: () -> Void
    var onAddRecipe: () -> Void
    var onAddIngredients: () -> Void
    var onAddCustomFood: () -> Void  // Nouveau
    var onDeleteEntry: (FoodEntry) -> Void

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // En-tête avec titre et calories
            HStack {
                Label {
                    Text(mealType.rawValue)
                        .font(.headline)
                } icon: {
                    // Icône basée sur le type de repas
                    Group {
                        switch mealType {
                        case .breakfast:
                            Image(systemName: "cup.and.saucer.fill")
                        case .lunch:
                            Image(systemName: "fork.knife")
                        case .dinner:
                            Image(systemName: "moon.stars.fill")
                        case .snack:
                            Image(systemName: "hand.thumbsup.fill")
                        }
                    }
                    .foregroundColor(mealTypeColor)
                }
                
                Spacer()
                
                // Calories du repas / objectif
                Text("\(Int(entriesCalories)) / \(targetCalories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            
            // Liste des entrées
            if entries.isEmpty {
                Text("Aucun aliment pour ce repas")
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(entries) { entry in
                    FoodEntryRow(entry: entry, onDelete: {
                        onDeleteEntry(entry)
                    })
                    .contentShape(Rectangle())
                    .swipeActions {
                        Button(role: .destructive) {
                            onDeleteEntry(entry)
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                    .overlay(
                        Button {
                            onDeleteEntry(entry)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(),
                        alignment: .trailing
                    )
                }
            }
            
            // Boutons d'ajout
            HStack(spacing: 0) {
                Button {
                    onAddPhoto()
                } label: {
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                        Text("Photo")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button {
                    barcode()
                } label: {
                        VStack {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 24))
                            Text("Code-barres")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                
                Button {
                    onAddRecipe()
                } label: {
                    VStack {
                        Image(systemName: "book")
                            .font(.system(size: 24))
                        Text("Recette")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button {
                    onAddIngredients()
                } label: {
                    VStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 24))
                        Text("Ingrédients")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Nouveau bouton pour les aliments personnalisés
                Button {
                    onAddCustomFood()
                } label: {
                    VStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                        Text("Personnalisé")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 10)
        }
        .padding(.horizontal)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var entriesCalories: Double {
        entries.reduce(0) { result, entry in
            result + entry.nutritionValues.calories
        }
    }
    
    private var mealTypeColor: Color {
        switch mealType {
        case .breakfast:
            return .orange
        case .lunch:
            return .blue
        case .dinner:
            return .purple
        case .snack:
            return .green
        }
    }
}

// Extension pour obtenir des icônes et couleurs pour les types de repas
extension MealType {
    var icon: some View {
        Group {
            switch self {
            case .breakfast:
                Image(systemName: "cup.and.saucer.fill")
            case .lunch:
                Image(systemName: "fork.knife")
            case .dinner:
                Image(systemName: "moon.stars.fill")
            case .snack:
                Image(systemName: "applelogo")
            }
        }
        .font(.title2)
    }
    
    var color: Color {
        switch self {
        case .breakfast:
            return .orange
        case .lunch:
            return .blue
        case .dinner:
            return .purple
        case .snack:
            return .green
        }
    }
}
