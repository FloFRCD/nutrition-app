//
//  MealTypeCard.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/02/2025.
//

import Foundation
import SwiftUI

struct MealTypeCard: View {
    let mealType: MealType
    let meals: [Meal]
    
    var body: some View {
        NavigationLink(destination: MealTypeDetailView(mealType: mealType, meals: meals)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(mealType.rawValue)
                    .font(.headline)
                
                Text("\(meals.count) repas générés")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let firstMeal = meals.first {
                    Text("Par exemple : \(firstMeal.name)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
