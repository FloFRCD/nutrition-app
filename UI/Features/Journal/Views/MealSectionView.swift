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
    var onAddCustomFood: () -> Void
    var onDeleteEntry: (FoodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // En-tête avec titre et calories
            HStack {
                Label {
                    Text(mealType.rawValue)
                        .font(.headline)
                        .foregroundColor(.black)
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
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            // Liste des entrées
            if entries.isEmpty {
                Text("Aucun aliment pour ce repas")
                    .foregroundColor(.gray)
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
            
            // Boutons d'ajout avec design amélioré
            HStack(spacing: 0) {
                ActionButton(
                    icon: "camera",
                    text: "Photo",
                    color: AppTheme.primaryPurple,
                    action: onAddPhoto
                )
                
                ActionButton(
                    icon: "barcode.viewfinder",
                    text: "Code-barres",
                    color: AppTheme.vibrantGreen,
                    action: barcode
                )
                
                ActionButton(
                    icon: "book",
                    text: "Recette",
                    color: AppTheme.primaryBlue,
                    action: onAddRecipe
                )
                
                ActionButton(
                    icon: "list.bullet",
                    text: "Ingrédients",
                    color: Color(hex: "D4AF37"),
                    action: onAddIngredients
                )
                
                ActionButton(
                    icon: "plus.circle",
                    text: "Personnalisé",
                    color: Color(hex: "FF6B6B"),
                    action: onAddCustomFood
                )
            }
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
        }
        .padding(.horizontal, 0)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
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
            return AppTheme.primaryBlue
        case .dinner:
            return AppTheme.primaryPurple
        case .snack:
            return AppTheme.vibrantGreen
        }
    }
}

// Nouveau composant pour les boutons d'action
struct ActionButton: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// Extension existante pour obtenir des icônes et couleurs pour les types de repas
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
            return AppTheme.primaryBlue
        case .dinner:
            return AppTheme.primaryPurple
        case .snack:
            return AppTheme.vibrantGreen
        }
    }
}
