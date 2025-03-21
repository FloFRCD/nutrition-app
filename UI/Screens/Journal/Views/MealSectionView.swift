//
//  MealSectionView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import SwiftUI

struct MealSectionView: View {
    let mealType: MealType
    let entries: [FoodEntry]
    let targetCalories: Int
    let onAddPhoto: () -> Void
    let onAddRecipe: () -> Void
    let onAddIngredients: () -> Void
    let onDeleteEntry: (FoodEntry) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête de la section (toujours visible)
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    // Icône du repas
                    mealType.icon
                        .foregroundColor(mealType.color)
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mealType.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(totalCalories) / \(targetCalories) kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Bouton + pour ajouter rapidement
                    Button(action: {
                        withAnimation { isExpanded = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onAddRecipe()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // Chevron indiquant l'état
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // Contenu déplié (aliments + actions)
            if isExpanded {
                           VStack(spacing: 10) {
                               // Liste des aliments
                               if entries.isEmpty {
                                   Text("Aucun aliment pour ce repas")
                                       .font(.caption)
                                       .foregroundColor(.gray)
                                       .padding()
                               } else {
                                   ForEach(entries) { entry in
                                       FoodEntryRow(entry: entry, onDelete: {
                                           onDeleteEntry(entry)
                                       })
                                   }
                                   .padding(.horizontal)
                               }
                               
                               // Boutons d'action
                               HStack(spacing: 8) {
                                   AddFoodButton(
                                       icon: "camera",
                                       text: "Photo",
                                       action: onAddPhoto
                                   )
                                   
                                   AddFoodButton(
                                       icon: "book",
                                       text: "Recette",
                                       action: onAddRecipe
                                   )
                                   
                                   AddFoodButton(
                                       icon: "list.bullet",
                                       text: "Ingrédients",
                                       action: onAddIngredients
                                   )
                               }
                               .padding([.horizontal, .bottom])
                           }
                           .background(Color(.tertiarySystemBackground))
                           .cornerRadius(12)
                           .transition(.opacity)
                       }
                   }
               }
    
    private var totalCalories: Int {
        Int(entries.reduce(0) { $0 + $1.nutritionValues.calories })
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

// Prévisualisations
struct MealSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MealSectionView(
            mealType: .breakfast,
            entries: [],
            targetCalories: 500,
            onAddPhoto: {},
            onAddRecipe: {},
            onAddIngredients: {},
            onDeleteEntry: { _ in }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
