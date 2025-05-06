//
//  IngredientEntryView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import SwiftUI
import Combine

struct IngredientEntryView: View {
    let mealType: MealType
    let onIngredientsSubmitted: ([String: Double]) -> Void

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var nutritionService: NutritionService
    @EnvironmentObject var journalViewModel: JournalViewModel

    @State private var ingredients: [IngredientEntry] = []
    @State private var isProcessing = false
    @State private var isShowingNutriaSearch = false
    @State private var isShowingCustomFoodsSelector = false
    @State private var iaSelectedUnit: ServingUnit = .gram

    struct IngredientEntry: Identifiable {
        let id = UUID()
        var name: String = ""
        var quantity: String = ""
        var nutritionInfo: NutritionValues? = nil
        var servingSize: Double = 100
        var servingUnit: ServingUnit = .gram
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        ingredientsCard
                        if !ingredients.isEmpty {
                            nutritionSummaryCard
                        }
                        addButtons
                        if !isProcessing {
                            submitButton
                        } else {
                            ProgressView("Ajout en cours...")
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.vibrantGreen))
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Ajouter des ingrédients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.vibrantGreen)
                }
            }
            .sheet(isPresented: $isShowingNutriaSearch) {
                NavigationView {
                    NutriaFoodSearchView { food, quantity, unit in
                        iaSelectedUnit = unit
                        addNutriaFood(food, quantity: quantity, unit: unit)
                    }
                    .environmentObject(nutritionService)
                }
            }
            .sheet(isPresented: $isShowingCustomFoodsSelector) {
                NavigationView {
                    CustomFoodSelectorView { customFood, quantity in
                        addCustomFood(customFood, quantity: quantity)
                    }
                    .environmentObject(nutritionService)
                }
            }
        }
    }

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingrédients")
                .font(.headline)
                .foregroundColor(AppTheme.vibrantGreen)

            if ingredients.isEmpty {
                Text("Aucun ingrédient ajouté")
                    .foregroundColor(AppTheme.secondaryText)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(16)
            } else {
                ForEach(ingredients.indices, id: \.self) { index in
                    ingredientRow(at: index)
                }
            }
        }
        .padding()
        .background(AppTheme.vibrantGreen.opacity(0.1))
        .cornerRadius(AppTheme.cardBorderRadius)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }

    private func ingredientRow(at index: Int) -> some View {
        let entry = ingredients[index]
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.name)
                    .font(.body)
                    .foregroundColor(AppTheme.vibrantGreen)

                Spacer()

                TextField("Qté", text: Binding(
                    get: { entry.quantity },
                    set: { ingredients[index].quantity = $0 }
                ))
                .keyboardType(.decimalPad)
                .submitLabel(.done)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
                .padding(6)
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.vibrantGreen.opacity(0.5), lineWidth: 1)
                )
                .foregroundColor(AppTheme.vibrantGreen)

                Text(entry.servingUnit.displayName)
                    .foregroundColor(AppTheme.vibrantGreen)
                    .font(.caption)

                Button {
                    withAnimation {
                        _ = ingredients.remove(at: index)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }

            if let nutrition = entry.nutritionInfo,
               let qty = Double(entry.quantity) {
                nutritionRow(nutrition: nutrition, quantity: qty, servingSize: entry.servingSize)
            }
        }
        .padding()
        .background(Color.white.opacity(0.4))
        .cornerRadius(12)
    }

    private func nutritionRow(nutrition: NutritionValues, quantity: Double, servingSize: Double) -> some View {
        let ratio = quantity / servingSize
        return HStack(spacing: 10) {
            Text("\(Int(nutrition.calories * ratio)) kcal")
                .foregroundColor(.orange)
            Text("P: \(String(format: "%.1fg", nutrition.proteins * ratio))")
                .foregroundColor(.blue)
            Text("G: \(String(format: "%.1fg", nutrition.carbohydrates * ratio))")
                .foregroundColor(.green)
            Text("L: \(String(format: "%.1fg", nutrition.fats * ratio))")
                .foregroundColor(.red)
        }
        .font(.caption)
        .padding(6)
        .background(AppTheme.backgroundBlob3)
        .cornerRadius(8)
    }

    private var addButtons: some View {
        VStack(spacing: 12) {
            Button {
                isShowingNutriaSearch = true
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Rechercher un aliment")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.vibrantGreen, lineWidth: 1.5))
                .cornerRadius(12)
            }

            Button {
                isShowingCustomFoodsSelector = true
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Mes aliments personnalisés")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.primaryBlue, lineWidth: 1.5))
                .cornerRadius(12)
            }
        }
    }

    private var nutritionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Valeurs nutritionnelles")
                .font(.headline)
                .foregroundColor(AppTheme.vibrantGreen)

            HStack {
                nutritionSummaryItem("Calories", "\(Int(totalNutrition.calories))", "kcal", .orange)
                nutritionSummaryItem("Protéines", String(format: "%.1f", totalNutrition.proteins), "g", .blue)
                nutritionSummaryItem("Glucides", String(format: "%.1f", totalNutrition.carbohydrates), "g", .green)
                nutritionSummaryItem("Lipides", String(format: "%.1f", totalNutrition.fats), "g", .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.cardBorderRadius)
    }

    private func nutritionSummaryItem(_ title: String, _ value: String, _ unit: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(AppTheme.secondaryText)
            HStack(spacing: 2) {
                Text(value).font(.headline).foregroundColor(color)
                Text(unit).font(.caption).foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var submitButton: some View {
        Button(action: submitIngredients) {
            Text("Ajouter au journal")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.actionButtonGradient)
                .cornerRadius(AppTheme.cardBorderRadius)
        }
        .disabled(ingredients.isEmpty)
        .opacity(ingredients.isEmpty ? 0.5 : 1)
    }

    private var totalNutrition: NutritionValues {
        ingredients.reduce(NutritionValues(calories: 0, proteins: 0, carbohydrates: 0, fats: 0, fiber: 0)) { acc, entry in
            guard let nutrition = entry.nutritionInfo,
                  let quantity = Double(entry.quantity) else { return acc }
            let ratio = quantity / 100.0
            return NutritionValues(
                calories: acc.calories + nutrition.calories * ratio,
                proteins: acc.proteins + nutrition.proteins * ratio,
                carbohydrates: acc.carbohydrates + nutrition.carbohydrates * ratio,
                fats: acc.fats + nutrition.fats * ratio,
                fiber: acc.fiber + nutrition.fiber * ratio
            )
        }
    }

    private func addNutriaFood(_ nutriaFood: NutriaFood, quantity: Double, unit: ServingUnit) {
        let food = nutriaFood.toFood()
        let nutritionValues = NutritionValues(
            calories: Double(food.calories),
            proteins: food.proteins,
            carbohydrates: food.carbs,
            fats: food.fats,
            fiber: food.fiber
        )

        ingredients.append(IngredientEntry(
            name: food.name,
            quantity: String(format: "%.1f", quantity),
            nutritionInfo: nutritionValues,
            servingSize: food.servingSize,
            servingUnit: unit
        ))
    }

    private func addCustomFood(_ customFood: CustomFood, quantity: Double) {
        withAnimation {
            ingredients.append(IngredientEntry(
                name: customFood.name,
                quantity: String(format: "%.1f", quantity),
                nutritionInfo: NutritionValues(
                    calories: Double(customFood.calories),
                    proteins: customFood.proteins,
                    carbohydrates: customFood.carbs,
                    fats: customFood.fats,
                    fiber: customFood.fiber
                )
            ))
        }
    }

    private func submitIngredients() {
        guard !ingredients.isEmpty else { return }
        isProcessing = true

        var entriesToSave: [FoodEntry] = []

        for entry in ingredients {
            guard let quantity = Double(entry.quantity),
                  let nutrition = entry.nutritionInfo else {
                continue
            }

            let ratio: Double
            let qtyForEntry: Double

            switch entry.servingUnit {
            case .gram, .milliliter:
                ratio = quantity / entry.servingSize
                qtyForEntry = ratio
            case .piece:
                ratio = quantity / entry.servingSize
                qtyForEntry = quantity
            }

            let food = Food(
                id: UUID(),
                name: entry.name,
                calories: Int(nutrition.calories), // 👈 pas multiplié
                proteins: nutrition.proteins,
                carbs: nutrition.carbohydrates,
                fats: nutrition.fats,
                fiber: nutrition.fiber,
                servingSize: entry.servingSize,
                servingUnit: entry.servingUnit,
                image: nil
            )

            let relativeQuantity = quantity / entry.servingSize
            let journalEntry = FoodEntry(
                id: UUID(),
                food: food,
                quantity: relativeQuantity,
                date: journalViewModel.selectedDate,
                mealType: mealType,
                source: .manual,
                unit: entry.servingUnit.displayName
            )
            entriesToSave.append(journalEntry)
        }

        print("💾 Enregistrement de \(entriesToSave.count) aliments dans le journal.")
        nutritionService.addMultipleFoodEntries(entriesToSave)

        onIngredientsSubmitted([:])

        DispatchQueue.main.async {
            isProcessing = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

