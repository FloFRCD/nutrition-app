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
    @State private var showCaloriesAlert = false
    @State private var caloriesInput: String = ""
    
    var body: some View {
        ZStack {
            // Fond animé
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // En-tête avec résumé nutritionnel modernisé
                NutritionSummaryHeader(viewModel: viewModel)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Sélecteur de date avec design amélioré
                DateSelectorView(selectedDate: $viewModel.selectedDate)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                
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
                .padding(.top, 10)

                
                                
                // Liste des repas de la journée
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            MealSectionView(
                                mealType: mealType,
                                entries: viewModel.entriesForMealType(mealType: mealType, date: viewModel.selectedDate),
                                targetCalories: viewModel.targetCaloriesFor(mealType: mealType),
                                onAddPhoto: { viewModel.showFoodPhotoCapture(for: mealType) },
                                barcode: { viewModel.showBarcodeScanner(for: mealType)},
                                onAddRecipe: { viewModel.showRecipeSelection(for: mealType) },
                                onAddIngredients: { viewModel.showIngredientEntry(for: mealType) },
                                onAddCustomFood: { viewModel.showCustomFoodEntry(for: mealType) },
                                onDeleteEntry: { entry in
                                    withAnimation {
                                        viewModel.removeFoodEntry(entry)
                                    }
                                }
                            )
                        }
                        
                        // Espace au bas de la page pour la TabBar
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
            }
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
            }
            
            // Notification observer
            NotificationCenter.default.addObserver(
                forName: .dismissAllSheets,
                object: nil,
                queue: .main
            ) { _ in
                DispatchQueue.main.async {
                    self.viewModel.activeSheet = nil
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(
                self,
                name: .dismissAllSheets,
                object: nil
            )
        }
        
        .sheet(item: $viewModel.activeSheet) { sheet in
            // Switch case inchangé
            switch sheet {
            // Vos cas existants...
            case .photoCapture(let mealType):
                FoodPhotoCaptureView(mealType: mealType)
                
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
            case .barcodeScanner(let mealType):
                    BarcodeScannerView(mealType: mealType)
                        .environmentObject(viewModel)
                
            case .burnedCaloriesEntry:
                        BurnedCaloriesEntryView(viewModel: viewModel)
                }
            }
        .navigationTitle("Journal Alimentaire")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func showBurnedCaloriesAlert() {
        caloriesInput = "\(Int(viewModel.getBurnedCalories(for: viewModel.selectedDate)))"
        showCaloriesAlert = true
    }
    
}
