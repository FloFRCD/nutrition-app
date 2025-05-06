//
//  CustomFoodEntryView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 28/03/2025.
//

// CustomFoodEntryView.swift

import SwiftUI

struct CustomFoodEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nutritionService: NutritionService
    @EnvironmentObject var journalViewModel: JournalViewModel

    let mealType: MealType

    @State private var foodName = ""
    @State private var calories = ""
    @State private var proteins = ""
    @State private var carbs = ""
    @State private var fats = ""
    @State private var fiber = "0"
    @State private var servingSize = "100"
    @State private var selectedUnit: ServingUnit = .gram

    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Ajoute un aliment personnalisé")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.vibrantGreen)
                        .padding(.top)

                    formCard

                    if isFormValid {
                        previewCard
                    }

                    addButton
                }
                .padding()
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.vibrantGreen)
                }
            }
            .alert("Informations incomplètes", isPresented: $showValidationAlert) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
    }

    private var formCard: some View {
        VStack(spacing: 16) {
            TextField("Nom de l'aliment", text: $foodName)
                .padding()
                .background(Color.white)
                .cornerRadius(12)

            HStack {
                TextField("Portion", text: $servingSize)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                
                Picker("Unité", selection: $selectedUnit) {
                    ForEach(ServingUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.menu)
            }

            VStack(spacing: 12) {
                nutritionField(label: "Calories", value: $calories, unit: "kcal")
                nutritionField(label: "Protéines", value: $proteins, unit: "g")
                nutritionField(label: "Glucides", value: $carbs, unit: "g")
                nutritionField(label: "Lipides", value: $fats, unit: "g")
                nutritionField(label: "Fibres", value: $fiber, unit: "g")
            }
        }
        .padding()
        .background(AppTheme.vibrantGreen.opacity(0.2))
        .cornerRadius(AppTheme.cardBorderRadius)
    }

    private func nutritionField(label: String, value: Binding<String>, unit: String) -> some View {
            HStack(alignment: .center) {
                Text(label)
                    .frame(minWidth: 80, alignment: .leading)
                Spacer()
                TextField("0", text: value)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                Text(unit)
                    .foregroundColor(.secondary)
            }
        }
    
    private var previewCard: some View {
        VStack(spacing: 16) {
            Text("\(Int(Double(calories) ?? 0)) kcal")
                .font(.title3)
                .foregroundColor(.orange)

            HStack(spacing: 20) {
                macronutrientLabel(value: Double(proteins) ?? 0, name: "Protéines", color: .blue)
                macronutrientLabel(value: Double(carbs) ?? 0, name: "Glucides", color: .green)
                macronutrientLabel(value: Double(fats) ?? 0, name: "Lipides", color: .red)
            }

            macronutrientBar
        }
        .padding()
        .background(AppTheme.backgroundBlob2.opacity(0.1))
        .cornerRadius(AppTheme.cardBorderRadius)
    }

    private func macronutrientLabel(value: Double, name: String, color: Color) -> some View {
        VStack {
            Text("\(Int(value))g")
                .font(.subheadline)
                .foregroundColor(color)
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var macronutrientBar: some View {
        GeometryReader { geometry in
            let proteinWidth = calculateWidth(for: Double(proteins) ?? 0, caloriesPerGram: 4, totalWidth: geometry.size.width)
            let carbWidth = calculateWidth(for: Double(carbs) ?? 0, caloriesPerGram: 4, totalWidth: geometry.size.width)
            let fatWidth = calculateWidth(for: Double(fats) ?? 0, caloriesPerGram: 9, totalWidth: geometry.size.width)

            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: proteinWidth)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: carbWidth)
                Rectangle()
                    .fill(Color.red)
                    .frame(width: fatWidth)
            }
            .frame(height: 10)
            .cornerRadius(5)
        }
        .frame(height: 10)
    }

    private var addButton: some View {
        Button("Ajouter au journal") {
            addFoodToJournal()
        }
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background { if isFormValid { AppTheme.actionButtonGradient } else { Color.gray }}
        .cornerRadius(AppTheme.cardBorderRadius)
        .disabled(!isFormValid)
    }

    private func calculateWidth(for grams: Double, caloriesPerGram: Double, totalWidth: CGFloat) -> CGFloat {
        let totalCalories = (Double(proteins) ?? 0) * 4 + (Double(carbs) ?? 0) * 4 + (Double(fats) ?? 0) * 9
        if totalCalories == 0 { return 0 }

        let proportion = (grams * caloriesPerGram) / totalCalories
        return CGFloat(proportion) * totalWidth
    }

    private var isFormValid: Bool {
        !foodName.isEmpty &&
        !calories.isEmpty &&
        !proteins.isEmpty &&
        !carbs.isEmpty &&
        !fats.isEmpty &&
        (Double(calories) ?? 0) > 0
    }

    private func addFoodToJournal() {
        guard isFormValid else {
            validationMessage = "Veuillez remplir tous les champs obligatoires."
            showValidationAlert = true
            return
        }

        guard let caloriesValue = Double(calories),
              let proteinsValue = Double(proteins),
              let carbsValue = Double(carbs),
              let fatsValue = Double(fats),
              let fiberValue = Double(fiber),
              let servingSizeValue = Double(servingSize) else {
            validationMessage = "Veuillez entrer des valeurs numériques valides."
            showValidationAlert = true
            return
        }

        let quantity = servingSizeValue / 100.0

        let food = Food(
            id: UUID(),
            name: foodName,
            calories: Int(caloriesValue),
            proteins: proteinsValue,
            carbs: carbsValue,
            fats: fatsValue,
            fiber: fiberValue,
            servingSize: servingSizeValue,
            servingUnit: selectedUnit,
            image: nil
        )

        nutritionService.saveCustomFood(food)
        let entry = FoodEntry(
            id: UUID(),
            food: food,
            quantity: quantity,
            date: journalViewModel.selectedDate,
            mealType: mealType,
            source: .favorite,
            unit: food.servingUnit.rawValue
        )

        nutritionService.addFoodEntry(entry)
        dismiss()
    }
}

