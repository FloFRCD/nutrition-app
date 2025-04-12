//
//  ProgressStatsCardView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 03/04/2025.
//

import Foundation
import SwiftUI

struct ProgressStatsCardView: View {
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @State private var currentIndex = 0
    @State private var tempStartingWeight: String = ""

    var body: some View {
        TabView(selection: $currentIndex) {
            goalProgressCard()
                .tag(0)
            
            if let profile = localDataManager.userProfile {
                weeklySummaryCard(profile: profile)
                    .tag(1)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 220)
        .background(Color.white)
        .cornerRadius(AppTheme.cardBorderRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            HStack(spacing: 6) {
                ForEach(0..<2) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.black : Color.gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 190)
        )
        .onAppear {
            tempStartingWeight = "\(Int(localDataManager.userProfile?.startingWeight ?? 0))"
        }
    }

    private func goalProgressCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progression")
                .font(.headline)
                .foregroundColor(.black)

            if let profile = localDataManager.userProfile {
                let (progress, isNegative) = calculateProgressToGoal(profile: profile)
                
                ProgressBar(
                    value: abs(progress),
                    color: isNegative ? .red : AppTheme.accent
                )
                .frame(height: 16)
                
                HStack {
                    Text("Poids de départ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Objectif")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    TextField("Départ", text: $tempStartingWeight)
                        .keyboardType(.decimalPad)
                        .frame(width: 60)
                        .onSubmit {
                            if let newStart = Double(tempStartingWeight) {
                                localDataManager.updateStartingWeight(to: newStart)
                            }
                        }

                    Spacer()

                    TextField("Objectif", value: Binding(
                        get: { profile.targetWeight ?? profile.weight },
                        set: { newTarget in
                            localDataManager.updateTargetWeight(to: newTarget)
                        }
                    ), format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                    .keyboardToolbar {
                            Button("Fermer") {
                                hideKeyboard()
                            }
                        }
                }

                Text(String(format: "%.1f %% %@", abs(progress * 100), isNegative ? "de régression" : "atteint"))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isNegative ? .red : AppTheme.accent)
            }
        }
        .padding()
    }

    private func weeklySummaryCard(profile: UserProfile) -> some View {
        let entries = LocalDataManager.shared.loadFoodEntries() ?? []
        let needs = NutritionCalculator.shared.calculateNeeds(for: profile)

        let last7Days = (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: Date())
        }

        let recent = entries.filter { entry in
            last7Days.contains(where: { Calendar.current.isDate($0, inSameDayAs: entry.date) })
        }

        let totalCalories = recent.reduce(0) { $0 + $1.nutritionValues.calories }
        let totalProteins = recent.reduce(0) { $0 + $1.nutritionValues.proteins }
        let totalCarbs = recent.reduce(0) { $0 + $1.nutritionValues.carbohydrates }
        let totalFats = recent.reduce(0) { $0 + $1.nutritionValues.fats }

        let targetCalories = needs.totalCalories * 7
        let targetProteins = needs.proteins * 7
        let targetCarbs = needs.carbs * 7
        let targetFats = needs.fats * 7

        let proteinPercent = targetProteins > 0 ? (totalProteins / targetProteins) * 100 : 0
        let carbsPercent = targetCarbs > 0 ? (totalCarbs / targetCarbs) * 100 : 0
        let fatsPercent = targetFats > 0 ? (totalFats / targetFats) * 100 : 0

        return VStack(alignment: .center, spacing: 12) {
            Text("Total sur les 7 derniers jours")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 12) {
                MacroCircleHomeView(
                    percent: proteinPercent,
                    color: .purple,
                    title: "Protéines",
                    value: "\(Int(totalProteins))g / \(Int(targetProteins))g"
                )
                .frame(maxWidth: .infinity)

                MacroCircleHomeView(
                    percent: carbsPercent,
                    color: .orange,
                    title: "Glucides",
                    value: "\(Int(totalCarbs))g / \(Int(targetCarbs))g"
                )
                .frame(maxWidth: .infinity)

                MacroCircleHomeView(
                    percent: fatsPercent,
                    color: .blue,
                    title: "Lipides",
                    value: "\(Int(totalFats))g / \(Int(targetFats))g"
                )
                .frame(maxWidth: .infinity)
            }

            Text("\(Int(totalCalories)) kcal sur \(Int(targetCalories)) kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
    }

    private func calculateProgressToGoal(profile: UserProfile) -> (Double, Bool) {
        guard let target = profile.targetWeight else { return (0.0, false) }
        let delta = profile.startingWeight - target
        let actuel = profile.startingWeight - profile.weight
        let ratio = delta != 0 ? actuel / delta : 0
        let isNegative = (delta > 0 && ratio < 0) || (delta < 0 && ratio > 1)
        return (ratio, isNegative)
    }
}


