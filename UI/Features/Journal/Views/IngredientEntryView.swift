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
            Form {
                ingredientsSection
                if !ingredients.isEmpty {
                    nutritionSummarySection
                }
                submitSection
            }
            .navigationTitle("Ajouter des ingrédients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
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
    
    private var ingredientsSection: some View {
        Section(header: Text("INGRÉDIENTS")) {
            if ingredients.isEmpty {
                Text("Aucun ingrédient ajouté")
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(ingredients.indices, id: \.self) { index in
                    ingredientRow(at: index)
                }
            }
            
            VStack(spacing: 10) {
                Button {
                    isShowingNutriaSearch = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Rechercher un aliment")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button {
                    isShowingCustomFoodsSelector = true
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Mes aliments personnalisés")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(BorderedButtonStyle())
            }
        }
    }
    
    // MARK: - Ligne d’ingrédient
    private func ingredientRow(at index: Int) -> some View {
        let entry = ingredients[index]
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.name)
                    .font(.headline)
                
                Spacer()
                
                TextField("Qté", text: Binding(
                    get: { entry.quantity },
                    set: { ingredients[index].quantity = $0 }
                ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .padding(.horizontal, 4)
                .background(Color(.systemGray6))
                .cornerRadius(4)
                
                Text(entry.servingUnit.displayName)
                    .foregroundColor(.secondary)
                
                Button {
                    withAnimation {
                        _ = ingredients.remove(at: index)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 22))
                }
                .padding(.leading, 6)
            }
            
            // Résumé nutritionnel si on a déjà les infos et une quantité valide
            if let nutrition = entry.nutritionInfo,
               let qty = Double(entry.quantity) {
                nutritionRow(
                    nutrition: nutrition,
                    quantity: qty,
                    servingSize: entry.servingSize
                )
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 2, x: 0, y: 1)
        .padding(.vertical, 2)
    }
    
    // MARK: - Résumé nutritionnel
    private func nutritionRow(nutrition: NutritionValues, quantity: Double, servingSize: Double) -> some View {
        // On calcule le ratio par rapport à la portion retournée par l’API
        let ratio = quantity / servingSize
        
        return HStack(spacing: 12) {
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
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(4)
    }


    
    private var nutritionSummarySection: some View {
        Section(header: Text("RÉSUMÉ NUTRITIONNEL")) {
            HStack {
                nutritionSummaryItem("Calories", "\(Int(totalNutrition.calories))", "kcal", .orange)
                nutritionSummaryItem("Protéines", String(format: "%.1f", totalNutrition.proteins), "g", .blue)
                nutritionSummaryItem("Glucides", String(format: "%.1f", totalNutrition.carbohydrates), "g", .green)
                nutritionSummaryItem("Lipides", String(format: "%.1f", totalNutrition.fats), "g", .red)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func nutritionSummaryItem(_ title: String, _ value: String, _ unit: String, _ color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).font(.headline).foregroundColor(color)
                Text(unit).font(.caption).foregroundColor(color)
            }
        }.frame(maxWidth: .infinity)
    }
    
    private var submitSection: some View {
        Section {
            if isProcessing {
                HStack {
                    Spacer()
                    ProgressView("Ajout en cours...")
                    Spacer()
                }
            } else {
                Button("Ajouter au journal") {
                    submitIngredients()
                }
                .disabled(ingredients.isEmpty)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .bold()
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
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

        for entry in ingredients {
            // 1) Récupérer la quantité et les infos nutritionnelles
            guard let quantity = Double(entry.quantity),
                  let nutrition = entry.nutritionInfo else {
                continue
            }

            // 2) Calculer le ratio et la quantité à passer au journal
            let ratio: Double
            let qtyForEntry: Double

            switch entry.servingUnit {
            case .gram, .milliliter:
                // si portion 100g ou 100mL → ratio = qty / 100
                ratio = quantity / entry.servingSize
                qtyForEntry = ratio

            case .piece:
                // si portion = 1 pièce → ratio = qty / 1 = qty
                ratio = quantity / entry.servingSize
                qtyForEntry = quantity
            }

            // 3) Construire l’objet Food avec la portion d’origine
            let food = Food(
                id: UUID(),
                name: entry.name,
                calories: Int((nutrition.calories * ratio).rounded()),
                proteins: nutrition.proteins * ratio,
                carbs: nutrition.carbohydrates * ratio,
                fats: nutrition.fats * ratio,
                fiber: nutrition.fiber * ratio,
                servingSize: entry.servingSize,   // ex: 100 ou 1
                servingUnit: entry.servingUnit,
                image: nil
            )

            // 4) Créer la FoodEntry en passant l’unité choisie
            let journalEntry = FoodEntry(
                id: UUID(),
                food: food,
                quantity: qtyForEntry,
                date: journalViewModel.selectedDate,
                mealType: mealType,
                source: .manual,
                unit: entry.servingUnit.displayName  // "g", "mL" ou "pc"
            )

            nutritionService.addFoodEntry(journalEntry)
        }

        // 5) Fermer la vue
        onIngredientsSubmitted([:])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

