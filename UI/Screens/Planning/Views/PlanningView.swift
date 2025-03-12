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
    @State private var currentPreferences: MealPreferences?
    @State private var selectedMealTypes: Set<MealType> = [.breakfast, .lunch, .dinner, .snack]
    
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
                        // Initialiser les préférences avec les données utilisateur si nécessaire
                        if currentPreferences == nil {
                            currentPreferences = createDefaultPreferences()
                        }
                        showingConfigSheet = true
                    } label: {
                        Label("Générer", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingConfigSheet) {
                if let unwrappedPreferences = currentPreferences {
                    MealConfigurationSheet(
                        preferences: Binding(
                            get: { unwrappedPreferences },
                            set: { self.currentPreferences = $0 }
                        ),
                        onGenerate: { preferences in
                            Task {
                                await viewModel.generateWeeklyPlan(with: preferences)
                            }
                        }
                    )
                } else {
                    // Créer des préférences par défaut si elles n'existent pas
                    let defaultPrefs = createDefaultPreferences()
                    MealConfigurationSheet(
                        preferences: Binding(
                            get: { defaultPrefs },
                            set: { self.currentPreferences = $0 }
                        ),
                        onGenerate: { preferences in
                            Task {
                                await viewModel.generateWeeklyPlan(with: preferences)
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            viewModel.setDependencies(localDataManager: localDataManager, aiService: AIService.shared)
        }
    }

private func createDefaultPreferences() -> MealPreferences {
    // Récupérer le profil utilisateur depuis localDataManager
    let userProfile = UserProfile.default
    
    return MealPreferences(
           bannedIngredients: [],
           preferredIngredients: [],
           defaultServings: 1,
           dietaryRestrictions: [],
           numberOfDays: 7,
           mealTypes: Array(selectedMealTypes),
           userProfile: userProfile
       )
}
}

// Extension pour créer un profil utilisateur par défaut
extension UserProfile {
static var `default`: UserProfile {
    UserProfile(
        name: "Utilisateur",
        age: 30,
        gender: .male,
        height: 170,
        weight: 70,
        bodyFatPercentage: nil,
        fitnessGoal: .maintainWeight,
        activityLevel: .moderatelyActive,
        dietaryRestrictions: [],
        activityDetails: ActivityDetails(
                    exerciseDaysPerWeek: 3,
                    exerciseDuration: 45,
                    exerciseIntensity: .moderate,
                    jobActivity: .seated,
                    dailyActivity: .moderate
                )
    )
}
}
