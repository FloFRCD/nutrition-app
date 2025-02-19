//
//  NextMealView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct NextMealView: View {
    let meal: Meal?
    
    var body: some View {
        if let meal = meal {
            FilledNextMealView(meal: meal) // Ici nous passons le meal
        } else {
            EmptyNextMealView()
        }
    }
}

private struct FilledNextMealView: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Prochain repas")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(meal.type.rawValue) - \(formatTime(meal.date))")
                        .foregroundColor(.gray)
                    Text(meal.name)
                        .font(.subheadline)
                        .bold()
                }
                
                Spacer()
                
                Text("\(meal.totalCalories) kcal")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


struct EmptyNextMealView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prochain repas")
                .font(.headline)
            
            VStack(alignment: .center, spacing: 12) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Planifiez votre premier repas")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button("Créer un planning") {
                    // Action à implémenter
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}



