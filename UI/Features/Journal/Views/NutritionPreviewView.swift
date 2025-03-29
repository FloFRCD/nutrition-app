//
//  NutritionPreviewView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 28/03/2025.
//

import Foundation
import SwiftUI

struct NutritionPreviewView: View {
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
    
    // Calcul des pourcentages de macronutriments
    private var proteinCalories: Double { proteins * 4 }
    private var carbCalories: Double { carbs * 4 }
    private var fatCalories: Double { fats * 9 }
    private var totalCalories: Double { proteinCalories + carbCalories + fatCalories }
    
    private var proteinPercentage: Double {
        totalCalories > 0 ? (proteinCalories / totalCalories) * 100 : 0
    }
    
    private var carbPercentage: Double {
        totalCalories > 0 ? (carbCalories / totalCalories) * 100 : 0
    }
    
    private var fatPercentage: Double {
        totalCalories > 0 ? (fatCalories / totalCalories) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(Int(calories)) kcal")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
                
                // Macronutriments avec pourcentages
                HStack(spacing: 12) {
                    macronutrientLabel(
                        value: proteins,
                        percentage: proteinPercentage,
                        label: "Protéines",
                        color: .blue
                    )
                    
                    macronutrientLabel(
                        value: carbs,
                        percentage: carbPercentage,
                        label: "Glucides",
                        color: .green
                    )
                    
                    macronutrientLabel(
                        value: fats,
                        percentage: fatPercentage,
                        label: "Lipides",
                        color: .red
                    )
                }
            }
            
            // Barre de proportion des macronutriments
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(proteinPercentage / 100))
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * CGFloat(carbPercentage / 100))
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: geometry.size.width * CGFloat(fatPercentage / 100))
                }
                .frame(height: 8)
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
    
    private func macronutrientLabel(value: Double, percentage: Double, label: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("\(Int(percentage))%")
                .font(.caption)
                .foregroundColor(color)
            
            Text("\(String(format: "%.1f", value))g")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
