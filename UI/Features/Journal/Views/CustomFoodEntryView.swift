//
//  CustomFoodEntryView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 28/03/2025.
//

import Foundation
import SwiftUI


import SwiftUI

struct CustomFoodEntryView: View {
    // Environnement
    @Environment(\.dismiss) var dismiss // Utilisons la version moderne au lieu de presentationMode
    @EnvironmentObject var nutritionService: NutritionService
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    // Paramètres
    let mealType: MealType
    
    // État de la vue
    @State private var foodName = ""
    @State private var calories = ""
    @State private var proteins = ""
    @State private var carbs = ""
    @State private var fats = ""
    @State private var fiber = "0"
    @State private var servingSize = "100"
    @State private var selectedUnit: ServingUnit = .gram
    
    // Validation
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    var body:
    some View {
        NavigationView {
            formContent
        }
    }
    
    
    private var formContent: some View {
           Form {
               basicInfoSection
               nutritionValuesSection
               
               // Aperçu nutritionnel si les données sont valides
               if isFormValid {
                   previewSection
               }
               
               // Bouton d'ajout
               addButtonSection
           }
           .navigationTitle("Aliment personnalisé")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .cancellationAction) {
                   Button("Annuler") {
                       dismiss()
                   }
               }
           }
           .alert("Informations incomplètes", isPresented: $showValidationAlert) {
               Button("OK") { }
           } message: {
               Text(validationMessage)
           }
       }
       
       // Section des informations de base
       private var basicInfoSection: some View {
           Section(header: Text("INFORMATIONS DE BASE")) {
               TextField("Nom de l'aliment", text: $foodName)
               
               HStack {
                   TextField("Portion", text: $servingSize)
                       .keyboardType(.decimalPad)
                       .multilineTextAlignment(.trailing)
                       .frame(width: 80)
                   
                   Text(selectedUnit.rawValue)
                   
                   Spacer()
                   
                   unitPicker
               }
           }
       }
       
       // Picker d'unités extrait
       private var unitPicker: some View {
           Picker("Unité", selection: $selectedUnit) {
               ForEach(ServingUnit.allCases, id: \.self) { unit in
                   Text(unit.rawValue).tag(unit)
               }
           }
           .pickerStyle(.menu)
       }
       
       // Section des valeurs nutritionnelles
       private var nutritionValuesSection: some View {
           Section(header: Text("VALEURS NUTRITIONNELLES")) {
               nutritionField(label: "Calories", value: $calories, unit: "kcal")
               nutritionField(label: "Protéines", value: $proteins, unit: "g")
               nutritionField(label: "Glucides", value: $carbs, unit: "g")
               nutritionField(label: "Lipides", value: $fats, unit: "g")
               nutritionField(label: "Fibres", value: $fiber, unit: "g")
           }
       }
       
       // Section d'aperçu
       private var previewSection: some View {
           Section(header: Text("APERÇU")) {
               macronutrientPreview
           }
       }
       
       // Section du bouton d'ajout
       private var addButtonSection: some View {
           Section {
               Button("Ajouter au journal") {
                   addFoodToJournal()
               }
               .frame(maxWidth: .infinity)
               .foregroundColor(.white)
               .padding()
               .background(isFormValid ? Color.blue : Color.gray)
               .cornerRadius(10)
               .disabled(!isFormValid)
           }
       }
    
    // Vue de champ nutritionnel
    private func nutritionField(label: String, value: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
    
    // Aperçu des macronutriments
    private var macronutrientPreview: some View {
        VStack(spacing: 10) {
            Text("\(Int(Double(calories) ?? 0)) kcal")
                .font(.headline)
                .foregroundColor(.orange)
            
            HStack(spacing: 20) {
                macronutrientLabel(value: Double(proteins) ?? 0, name: "Protéines", color: .blue)
                macronutrientLabel(value: Double(carbs) ?? 0, name: "Glucides", color: .green)
                macronutrientLabel(value: Double(fats) ?? 0, name: "Lipides", color: .red)
            }
            
            // Barre de proportion des macronutriments
            macronutrientBar
        }
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
    
    // Calcul de la largeur proportionnelle pour la barre de macronutrients
    private func calculateWidth(for grams: Double, caloriesPerGram: Double, totalWidth: CGFloat) -> CGFloat {
        let totalCalories = (Double(proteins) ?? 0) * 4 + (Double(carbs) ?? 0) * 4 + (Double(fats) ?? 0) * 9
        if totalCalories == 0 { return 0 }
        
        let proportion = (grams * caloriesPerGram) / totalCalories
        return CGFloat(proportion) * totalWidth
    }
    
    // Validation du formulaire
    private var isFormValid: Bool {
        !foodName.isEmpty &&
        !calories.isEmpty &&
        !proteins.isEmpty &&
        !carbs.isEmpty &&
        !fats.isEmpty &&
        (Double(calories) ?? 0) > 0
    }
    
    // Ajout de l'aliment au journal
    // Dans CustomFoodEntryView, modifiez la méthode addFoodToJournal() comme suit:
    private func addFoodToJournal() {
        
        // Validation
        guard isFormValid else {
            validationMessage = "Veuillez remplir tous les champs obligatoires."
            showValidationAlert = true
            return
        }
        
        // Vérification des valeurs numériques
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
        print("➡️ Quantité calculée : \(quantity), Portion entrée : \(servingSizeValue)")

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
