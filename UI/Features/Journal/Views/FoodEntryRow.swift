//
//  FoodEntryRow.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import Foundation
import SwiftUI

struct FoodEntryRow: View {
    let entry: FoodEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Icône source
            Image(systemName: sourceIcon(for: entry.source))
                .foregroundColor(entry.source.color)
                .frame(width: 30, height: 30)
                .background(entry.source.color.opacity(0.1))
                .clipShape(Circle())
            
            // Nom et quantité
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.food.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("\(Int(entry.quantity)) \(entry.food.servingUnit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Macros et calories
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(entry.nutritionValues.calories)) kcal")
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack(spacing: 5) {
                    MacroLabel(value: Int(entry.nutritionValues.proteins), label: "P", color: .purple)
                    MacroLabel(value: Int(entry.nutritionValues.carbohydrates), label: "G", color: .yellow)
                    MacroLabel(value: Int(entry.nutritionValues.fats), label: "L", color: .red)
                }
            }
            
            // Bouton de suppression
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.7))
                    .padding(.leading, 8)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    private func sourceIcon(for source: FoodEntry.FoodSource) -> String {
        switch source {
        case .manual: return "keyboard"
        case .foodPhoto: return "camera"
        case .barcode: return "barcode"
        case .recipe: return "book"
        case .favorite: return "star.fill"
        }
    }
}

// Extension pour obtenir des couleurs pour les sources d'entrées
extension FoodEntry.FoodSource {
    var color: Color {
        switch self {
        case .manual: return .blue
        case .foodPhoto: return .green
        case .barcode: return .orange
        case .recipe: return .purple
        case .favorite: return .yellow
        }
    }
}

struct MacroLabel: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        Text("\(value)\(label)")
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}
