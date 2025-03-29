//
//  JournalView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import Foundation
import SwiftUI

struct JournalView: View {
    @StateObject var viewModel = JournalViewModel()
    @EnvironmentObject var localDataManager: LocalDataManager
    @EnvironmentObject var nutritionService: NutritionService
    @State private var hasAppeared = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // En-tête avec résumé nutritionnel
                NutritionSummaryHeader(viewModel: viewModel)
                
                // Sélecteur de date
                DateSelectorView(selectedDate: $viewModel.selectedDate)
                
                // Liste des repas de la journée
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            MealSectionView(
                                mealType: mealType,
                                entries: viewModel.entriesForMealType(mealType: mealType, date: viewModel.selectedDate),
                                targetCalories: viewModel.targetCaloriesFor(mealType: mealType),
                                onAddPhoto: { viewModel.showFoodPhotoCapture(for: mealType) },
                                onAddRecipe: { viewModel.showRecipeSelection(for: mealType) },
                                onAddIngredients: { viewModel.showIngredientEntry(for: mealType) },
                                onAddCustomFood: { viewModel.showCustomFoodEntry(for: mealType) },
                                onDeleteEntry: { entry in
                                    print("onDeleteEntry")
                                    withAnimation {
                                        viewModel.removeFoodEntry(entry)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            if !hasAppeared {
                print("📱 JournalView apparaît pour la première fois")
                hasAppeared = true
            } else {
                print("📱 JournalView réapparaît")
            }
        }
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .photoCapture(let mealType):
                FoodPhotoCaptureView(mealType: mealType) { image in
                    Task {
                        await viewModel.processAndAddFoodPhoto(image, mealType: mealType, date: viewModel.selectedDate)
                    }
                }
                
            case .recipeSelection(let mealType):
                RecipeSelectionForJournalView(mealType: mealType) { recipe, servings in
                    viewModel.addDetailedRecipeToJournal(recipe, servings: servings, mealType: mealType)
                }
                .environmentObject(localDataManager)
                
            case .ingredientEntry(let mealType):
                IngredientEntryView(mealType: mealType) { ingredients in
                    // Ne traitez les ingrédients que s'ils ne sont pas vides
                    if !ingredients.isEmpty {
                        Task {
                            await viewModel.processAndAddIngredients(ingredients, mealType: mealType, date: viewModel.selectedDate)
                        }
                    }
                }
                
            case .customFoodEntry(let mealType):
                CustomFoodEntryView(mealType: mealType)
                    .environmentObject(localDataManager)
                    .environmentObject(nutritionService)
                    .environmentObject(viewModel)
            
            case .customFoodEntry(let mealType):
                    CustomFoodEntryView(mealType: mealType)
                        .environmentObject(viewModel)
                        .environmentObject(nutritionService)
                        
            case .myFoodsSelector(let mealType):
                    NavigationView {
                        CustomFoodSelectorView { customFood, quantity in
                            // Créer une entrée alimentaire à partir de l'aliment personnalisé
                            let food = customFood.toFood()
                            let entry = FoodEntry(
                                id: UUID(),
                                food: food,
                                quantity: quantity / food.servingSize,
                                date: viewModel.selectedDate,
                                mealType: mealType,
                                source: .favorite
                            )
                            
                            // Ajouter au journal et fermer la feuille
                            viewModel.addFoodEntry(entry)
                            viewModel.activeSheet = nil
                        }
                        .environmentObject(nutritionService)
                    }
                }
            }
        .navigationTitle("Journal Alimentaire")
    }
}
