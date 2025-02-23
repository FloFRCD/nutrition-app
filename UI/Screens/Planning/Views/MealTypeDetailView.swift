//
//  MealTypeDetailView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/02/2025.
//

import Foundation
import SwiftUI

struct MealTypeDetailView: View {
    let mealType: MealType
    let meals: [Meal]
    
    var sortedMeals: [Meal] {
        meals.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        List {
            ForEach(sortedMeals) { meal in
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(meal.name)
                            .font(.headline)
                        
                        Text("≃ \(meal.totalCalories) calories")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ForEach(meal.foods) { food in
                            HStack {
                                Text("• \(food.name)")
                                Spacer()
                                Text("\(Int(food.servingSize)) \(food.servingUnit.rawValue)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                } header: {
                    Text(formatDate(meal.date))
                }
            }
        }
        .navigationTitle(mealType.rawValue)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }
}
