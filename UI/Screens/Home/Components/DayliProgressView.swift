//
//  DayliProgressView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct DailyProgressView: View {
    let userProfile: UserProfile?
    @Binding var isExpanded: Bool 
    
    var body: some View {
        if let profile = userProfile {
            let needs = NutritionCalculator.shared.calculateNeeds(for: profile)
            
            VStack(spacing: 5) {
                Text("Aujourd'hui")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    // Calories
                    StatBox(
                        title: "Calories",
                        currentValue: "0",
                        currentUnit: "cal",
                        // Utiliser l'arrondi pour éviter les décimales
                        targetValue: "\(Int(needs.targetCalories.rounded()))",
                        targetUnit: "kcal",
                        type: .calories
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = true
                        }
                    }
                    
                    // Protéines
                    StatBox(
                        title: "Protéines",
                        currentValue: "0",
                        currentUnit: "g",
                        // Utiliser l'arrondi pour éviter les décimales
                        targetValue: "\(Int(needs.proteins.rounded()))",
                        targetUnit: "g",
                        type: .proteins
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = true
                        }
                    }
                    
                    // Eau
                    StatBox(
                        title: "Eau",
                        currentValue: "0",
                        currentUnit: "L",
                        targetValue: "2.5",
                        targetUnit: "L",
                        type: .water
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = true
                        }
                    }
                }
            }
            if isExpanded {
                ExpandedView(needs: needs, isExpanded: $isExpanded)
                    .transition(.move(edge: .bottom))
            }
        } else {
            Text("Profil utilisateur non disponible")
                .foregroundColor(.gray)
        }
    }
}

struct StatBox: View {
    let title: String
    let currentValue: String
    let currentUnit: String
    let targetValue: String
    let targetUnit: String
    let type: StatType
    
    enum StatType {
        case calories
        case proteins
        case water
        
        var gradient: LinearGradient {
            switch self {
            case .calories:
                return LinearGradient(
                    colors: [Color.orange.opacity(0.8), Color.red.opacity(0.3)],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            case .proteins:
                return LinearGradient(
                    colors: [Color.purple.opacity(0.6), Color.purple.opacity(0.3)],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            case .water:
                return LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.subheadline)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Actuel")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(currentValue)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    Text(currentUnit)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Objectif")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(targetValue)
                        .font(.callout)
                        .bold()
                        .foregroundColor(.white)
                    Text(targetUnit)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(type.gradient)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct ExpandedView: View {
    let needs: NutritionCalculator.NutritionNeeds
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Nutrition")
                    .font(.title2)
                    .bold()
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            // Contenu détaillé
            VStack(spacing: 15) {
                DetailedStatBox(
                    title: "Calories",
                    current: "0",
                    currentUnit: "cal",
                    // Utiliser l'arrondi pour éviter les décimales
                    target: "\(Int(needs.targetCalories.rounded()))",
                    targetUnit: "kcal",
                    maintenance: "\(Int(needs.maintenanceCalories.rounded()))kcal"
                )
                
                DetailedStatBox(
                    title: "Protéines",
                    current: "0",
                    currentUnit: "g",
                    target: "\(Int(needs.proteins.rounded()))",
                    targetUnit: "g",
                    maintenance: "\(Int(needs.proteins.rounded()))g"
                )
                
                DetailedStatBox(
                    title: "Glucides",
                    current: "0",
                    currentUnit: "g",
                    target: "\(Int(needs.carbs.rounded()))",
                    targetUnit: "g",
                    maintenance: "\(Int(needs.carbs.rounded()))g"
                )
                
                DetailedStatBox(
                    title: "Lipides",
                    current: "0",
                    currentUnit: "g",
                    target: "\(Int(needs.fats.rounded()))",
                    targetUnit: "g",
                    maintenance: "\(Int(needs.fats.rounded()))g"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }
}

struct DetailedStatBox: View {
    let title: String
    let current: String
    let currentUnit: String
    let target: String
    let targetUnit: String
    let maintenance: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Actuel")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(current)
                            .font(.title2)
                            .bold()
                        Text(currentUnit)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Objectif")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(target)
                            .font(.title2)
                            .bold()
                        Text(targetUnit)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Text("Maintenance: \(maintenance)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}
