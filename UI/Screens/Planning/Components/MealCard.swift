//
//  MealCard.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct MealCard: View {
    let mealTime: String
    var meal: Meal?  // Optionnel car on peut avoir une carte sans repas assigné
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(mealTime)
                .font(.headline)
            
            if let meal = meal {
                // Si un repas est assigné
                VStack(alignment: .leading, spacing: 5) {
                    Text(meal.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    if !meal.foods.isEmpty {
                        Text("\(meal.totalCalories) calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                // Si pas de repas assigné
                Text("Aucun repas planifié")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
