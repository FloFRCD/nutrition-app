//
//  PlanningView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct PlanningView: View {
    @EnvironmentObject private var localDataManager: LocalDataManager
    @StateObject private var viewModel: PlanningViewModel
    @State private var showingConfigSheet = false
    @State private var currentPreferences = MealPreferences(
        bannedIngredients: [],
        preferredIngredients: [],
        defaultServings: 2,
        dietaryRestrictions: [],
        numberOfDays: 1,
        mealTypes: [.lunch, .dinner]
    )
    
    init() {
        _viewModel = StateObject(wrappedValue: PlanningViewModel())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 20) {
                        ForEach(viewModel.meals) { meal in
                            MealCard(mealTime: meal.type.rawValue, meal: meal)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Planning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingConfigSheet = true
                    } label: {
                        Label("Générer", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingConfigSheet) {
                MealConfigurationSheet(
                    preferences: $currentPreferences,
                    onGenerate: { preferences in
                        // Test des données
                        print("--- Préférences de génération ---")
                        print("Nombre de portions: \(preferences.defaultServings)")
                        print("Nombre de jours: \(preferences.numberOfDays)")
                        print("Types de repas: \(preferences.mealTypes.map { $0.rawValue })")
                        print("Restrictions: \(preferences.dietaryRestrictions.map { $0.rawValue })")
                        print("Ingrédients bannis: \(preferences.bannedIngredients)")
                        print("Ingrédients préférés: \(preferences.preferredIngredients)")
                        print("\nPrompt IA format:")
                        print(preferences.aiPromptFormat)
                        print("-------------------------------")
                        
                        Task {
                                                   await viewModel.generateWeeklyPlan(with: preferences)
                                               }
                    }
                )
            }
            .alert("Erreur", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
        .onAppear {
                    viewModel.setDependencies(
                        localDataManager: localDataManager,
                        aiService: AIService.shared
                    )
        }
    }
}
