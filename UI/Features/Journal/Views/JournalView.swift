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
    @StateObject private var storeKitManager = StoreKitManager.shared
    @State private var showPremiumSheet = false
    
    var body: some View {
        journalContent
    }

    private var journalContent: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                NutritionSummaryHeader(viewModel: viewModel)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.top, 16)

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
                
                mealList
            }
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
            }

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
            switch sheet {
            case .photoCapture(let mealType):
                FoodPhotoCaptureView(mealType: mealType)

            case .recipeSelection(let mealType):
                RecipeSelectionForJournalView(mealType: mealType) { recipe, servings in
                    viewModel.addDetailedRecipeToJournal(recipe, servings: servings, mealType: mealType)
                }
                .environmentObject(localDataManager)

            case .ingredientEntry(let mealType):
                IngredientEntryView(mealType: mealType) { ingredients in
                    if !ingredients.isEmpty {
                        Task {
                            await viewModel.processAndAddIngredients(ingredients, mealType: mealType, date: viewModel.selectedDate)
                        }
                    }
                }

            case .customFoodEntry(let mealType):
                CustomFoodEntryView(mealType: mealType)
                    .environmentObject(viewModel)
                    .environmentObject(nutritionService)

            case .myFoodsSelector(let mealType):
                NavigationView {
                    CustomFoodSelectorView { customFood, quantity in
                        let food = customFood.toFood()
                        let entry = FoodEntry(
                            id: UUID(),
                            food: food,
                            quantity: quantity / food.servingSize,
                            date: viewModel.selectedDate,
                            mealType: mealType,
                            source: .favorite
                        )
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
        .sheet(isPresented: $showPremiumSheet) {
            PremiumView()
        }
    }
    
    @ViewBuilder
    private var mealList: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    MealSectionView(
                        mealType: mealType,
                        entries: viewModel.entriesForMealType(mealType: mealType, date: viewModel.selectedDate),
                        targetCalories: viewModel.targetCaloriesFor(mealType: mealType),
                        onAddPhoto: {
                            if storeKitManager.isPremiumUser {
                                viewModel.showFoodPhotoCapture(for: mealType)
                            } else {
                                showPremiumSheet = true
                            }
                        },
                        barcode: {
                            if storeKitManager.isPremiumUser {
                                viewModel.showBarcodeScanner(for: mealType)
                            } else {
                                showPremiumSheet = true
                            }
                        },
                        onAddRecipe: { viewModel.showRecipeSelection(for: mealType) },
                        onAddIngredients: { viewModel.showIngredientEntry(for: mealType) },
                        onAddCustomFood: { viewModel.showCustomFoodEntry(for: mealType) },
                        onDeleteEntry: { entry in
                            withAnimation {
                                viewModel.removeFoodEntry(entry)
                            }
                        },
                        isPremium: storeKitManager.isPremiumUser,
                        showPremiumSheet: $showPremiumSheet
                    )
                }

                Spacer().frame(height: 100)
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }


    
    private func showBurnedCaloriesAlert() {
        caloriesInput = "\(Int(viewModel.getBurnedCalories(for: viewModel.selectedDate)))"
        showCaloriesAlert = true
    }
    
}
