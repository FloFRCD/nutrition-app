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
                        // Dans JournalView
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            MealSectionView(
                                mealType: mealType,
                                entries: viewModel.entriesForMealType(mealType: mealType, date: viewModel.selectedDate),
                                targetCalories: viewModel.targetCaloriesFor(mealType: mealType),
                                onAddPhoto: { viewModel.showFoodPhotoCapture(for: mealType) },
                                onAddRecipe: { viewModel.showRecipeSelection(for: mealType) },
                                onAddIngredients: { viewModel.showIngredientEntry(for: mealType) },
                                onDeleteEntry: { entry in
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
                    Task {
                        await viewModel.processAndAddIngredients(ingredients, mealType: mealType, date: viewModel.selectedDate)
                    }
                }
            }
        }        .navigationTitle("Journal Alimentaire")
    }
}

// Prévisualisations
struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .environmentObject(LocalDataManager.shared)
    }
}
