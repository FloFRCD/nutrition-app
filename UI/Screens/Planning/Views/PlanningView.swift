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
        mealTypes: [.breakfast, .lunch, .dinner]
    )
    
    init() {
        _viewModel = StateObject(wrappedValue: PlanningViewModel())
    }
    
    var groupedMeals: [MealType: [Meal]] {
        Dictionary(grouping: viewModel.meals) { $0.type }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 20) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            if let meals = groupedMeals[mealType], !meals.isEmpty {
                                MealTypeCard(mealType: mealType, meals: meals)
                            }
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
                        Task {
                            await viewModel.generateWeeklyPlan(with: preferences)
                        }
                    }
                )
            }
        }
        .onAppear {
            viewModel.setDependencies(localDataManager: localDataManager, aiService: AIService.shared)
        }
    }
}
