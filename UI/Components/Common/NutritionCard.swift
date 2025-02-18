//
//  NutritionCard.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct NutritionCard: View {
    let nutritionInfo: NutritionInfo
    var showDetails: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Calories")
                    .font(.headline)
                Spacer()
                Text("\(nutritionInfo.calories) kcal")
                    .font(.title2)
                    .bold()
            }
            
            if showDetails {
                Divider()
                
                MacroRow(name: "Protéines", value: nutritionInfo.proteins)
                MacroRow(name: "Glucides", value: nutritionInfo.carbs)
                MacroRow(name: "Lipides", value: nutritionInfo.fats)
                
                if let fiber = nutritionInfo.fiber {
                    MacroRow(name: "Fibres", value: fiber)
                }
                if let sugar = nutritionInfo.sugar {
                    MacroRow(name: "Sucres", value: sugar)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

private struct MacroRow: View {
    let name: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.1f g", value))
        }
    }
}
