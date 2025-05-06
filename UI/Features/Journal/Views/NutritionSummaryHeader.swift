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
        VStack(spacing: 16) {
            // Calories restantes avec cercle progressif modernisé
            HStack(spacing: 30) {
                // Cercle de progression
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: min(caloriesProgress, 1.0))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [AppTheme.primaryPurple, AppTheme.primaryBlue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(remainingCalories)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
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
                            .foregroundColor(.black)
                        Text("Consommées")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("\(Int(burnedCalories))")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Dépensées")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Boutons de macronutriments avec design amélioré
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    MacroButton(
                        title: "Lipides",
                        isSelected: selectedMacro == .lipids,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).fats,
                            goal: getNutritionalNeeds().fats
                        ),
                        color: .red,
                        action: { selectedMacro = selectedMacro == .lipids ? .none : .lipids }
                    )
                    
                    MacroButton(
                        title: "Protéines",
                        isSelected: selectedMacro == .proteins,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).proteins,
                            goal: getNutritionalNeeds().proteins
                        ),
                        color: AppTheme.primaryPurple,
                        action: { selectedMacro = selectedMacro == .proteins ? .none : .proteins }
                    )
                    
                    MacroButton(
                        title: "Glucides",
                        isSelected: selectedMacro == .carbs,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).carbohydrates,
                            goal: getNutritionalNeeds().carbs
                        ),
                        color: Color(hex: "D4AF37"),
                        action: { selectedMacro = selectedMacro == .carbs ? .none : .carbs }
                    )
                    
                    MacroButton(
                        title: "Fibres",
                        isSelected: selectedMacro == .fiber,
                        percentage: calculatePercentage(
                            consumed: viewModel.totalNutritionForDate(viewModel.selectedDate).fiber,
                            goal: getNutritionalNeeds().fiber
                        ),
                        color: AppTheme.vibrantGreen,
                        action: { selectedMacro = selectedMacro == .fiber ? .none : .fiber }
                    )
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            
            // Afficher les détails du macronutriment sélectionné si applicable
            if selectedMacro != .none {
                MacroDetailView(macroType: selectedMacro, viewModel: viewModel)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
            Button(action: {
                viewModel.showBurnedCaloriesEntry()
            }) {
                Label("Ajouter calories brûlées", systemImage: "flame.fill")
                    .font(.callout)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
        .animation(.easeInOut, value: selectedMacro)
    }
    
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
            return viewModel.getBurnedCalories(for: viewModel.selectedDate)
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

    // MacroButton modernisé
    struct MacroButton: View {
        let title: String
        let isSelected: Bool
        let percentage: Int
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.footnote)
                        .fontWeight(.medium)
                    
                    Text("\(percentage)%")
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color.opacity(0.1) : Color.gray.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color.opacity(0.3) : Color.clear, lineWidth: 1)
                )
                .foregroundColor(isSelected ? color : .gray)
            }
        }
    }

    // MacroDetailView modernisé
    struct MacroDetailView: View {
        let macroType: NutritionSummaryHeader.MacroType
        @ObservedObject var viewModel: JournalViewModel
        
        var body: some View {
            HStack {
                // Cercle de progression
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
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
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("\(Int(current))g sur \(Int(goal))g")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding()
            .background(color.opacity(0.05))
            .cornerRadius(16)
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
            case .proteins: return AppTheme.primaryPurple
            case .carbs: return Color(hex: "D4AF37")
            case .fiber: return AppTheme.vibrantGreen
            case .none: return .gray
            }
        }
    }
