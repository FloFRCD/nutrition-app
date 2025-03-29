//
//  NutritionSummaryHeader.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import SwiftUI

struct NutritionSummaryHeader: View {
    @ObservedObject var viewModel: JournalViewModel
    @State private var selectedMacro: MacroType = .none
    
    enum MacroType {
        case none, lipids, proteins, carbs, fiber
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Calories restantes avec cercle progressif
            HStack(spacing: 30) {
                // Cercle de progression
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: min(caloriesProgress, 1.0))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(remainingCalories)")
                            .font(.system(size: 24, weight: .bold))
                        Text("kcal")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Restantes")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                // Calories consommées et dépensées
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("\(Int(consumedCalories))")
                            .font(.headline)
                        Text("Consommées")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("\(Int(burnedCalories))")
                            .font(.headline)
                        Text("Dépensées")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Boutons de macronutriments
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    MacroButton(
                        title: "Lipides",
                        isSelected: selectedMacro == .lipids,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).fats,
                            goal: getNutritionalNeeds().fats
                        ),
                        action: { selectedMacro = selectedMacro == .lipids ? .none : .lipids }
                    )
                    
                    MacroButton(
                        title: "Protéines",
                        isSelected: selectedMacro == .proteins,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).proteins,
                            goal: getNutritionalNeeds().proteins
                        ),
                        action: { selectedMacro = selectedMacro == .proteins ? .none : .proteins }
                    )
                    
                    MacroButton(
                        title: "Glucides",
                        isSelected: selectedMacro == .carbs,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).carbohydrates,
                            goal: getNutritionalNeeds().carbs
                        ),
                        action: { selectedMacro = selectedMacro == .carbs ? .none : .carbs }
                    )
                    
                    MacroButton(
                        title: "Fibres",
                        isSelected: selectedMacro == .fiber,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).fiber,
                            goal: getNutritionalNeeds().fiber
                        ),
                        action: { selectedMacro = selectedMacro == .fiber ? .none : .fiber }
                    )
                }
                .padding(.horizontal)
            }
            
            // Afficher les détails du macronutriment sélectionné si applicable
            if selectedMacro != .none {
                MacroDetailView(macroType: selectedMacro, viewModel: viewModel)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground))
        .animation(.easeInOut, value: selectedMacro)
    }
    
    // Méthode pour obtenir les besoins nutritionnels depuis le calculateur centralisé
    private func getNutritionalNeeds() -> NutritionalNeeds {
        return NutritionCalculator.shared.calculateNeeds(for: viewModel.userProfile)
    }
    
    // Propriétés calculées
    private var consumedCalories: Double {
        let nutrition = viewModel.totalNutritionForDate(viewModel.selectedDate)
        return nutrition.calories
    }
    
    // Fonction helper pour calculer le pourcentage
    func calculatePercentage(consumed: Double, goal: Double) -> Int {
        if goal <= 0 { return 0 }
        return min(Int((consumed / goal) * 100), 100)
    }
    
    private var burnedCalories: Double {
        // À implémenter si vous suivez les exercices
        return 0
    }
    
    private var remainingCalories: Int {
        let total = getNutritionalNeeds().totalCalories
        return Int(total - consumedCalories + burnedCalories)
    }
    
    private var caloriesProgress: Double {
        let totalCalories = getNutritionalNeeds().totalCalories
        if totalCalories == 0 { return 0 }
        return consumedCalories / totalCalories
    }
}

struct MacroButton: View {
    let title: String
    let isSelected: Bool
    let percentage: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.footnote)
                
                Text("\(percentage)%")
                    .font(.system(size: 12, weight: .bold))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(20)
            .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

struct MacroDetailView: View {
    let macroType: NutritionSummaryHeader.MacroType
    @ObservedObject var viewModel: JournalViewModel
    
    var body: some View {
        HStack {
            // Cercle de progression
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold))
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text("\(Int(current))g sur \(Int(goal))g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    private var title: String {
        switch macroType {
        case .lipids: return "Lipides"
        case .proteins: return "Protéines"
        case .carbs: return "Glucides"
        case .fiber: return "Fibres"
        case .none: return ""
        }
    }
    
    private var current: Double {
        let nutrition = viewModel.totalNutritionForDate(viewModel.selectedDate)
        switch macroType {
        case .lipids: return nutrition.fats
        case .proteins: return nutrition.proteins
        case .carbs: return nutrition.carbohydrates
        case .fiber: return nutrition.fiber
        case .none: return 0
        }
    }
    
    private var goal: Double {
        let needs = NutritionCalculator.shared.calculateNeeds(for: viewModel.userProfile)
        switch macroType {
        case .lipids: return needs.fats
        case .proteins: return needs.proteins
        case .carbs: return needs.carbs
        case .fiber: return needs.fiber
        case .none: return 0
        }
    }
    
    private var progress: Double {
        if goal == 0 { return 0 }
        return min(current / goal, 1.0)
    }
    
    private var color: Color {
        switch macroType {
        case .lipids: return .red
        case .proteins: return .purple
        case .carbs: return .yellow
        case .fiber: return .green
        case .none: return .gray
        }
    }
}
