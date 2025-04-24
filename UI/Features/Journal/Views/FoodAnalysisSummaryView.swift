//
//  FoodAnalysisSummaryView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 29/03/2025.
//

import Foundation
import SwiftUI

struct FoodAnalysisSummaryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    let image: UIImage
    let mealType: MealType
    let onCompleteAndDismissAll: () -> Void
    
    @State private var foodName: String
    @State private var calories: String
    @State private var proteins: String
    @State private var carbs: String
    @State private var fats: String
    @State private var fiber: String
    
    init(image: UIImage, foodName: String, nutritionInfo: NutritionInfo, mealType: MealType, onCompleteAndDismissAll: @escaping () -> Void) {
        self.image = image
        self.mealType = mealType
        self.onCompleteAndDismissAll = onCompleteAndDismissAll
        
        // Initialisation des états
        _foodName = State(initialValue: foodName)
        _calories = State(initialValue: String(Int(nutritionInfo.calories)))
        _proteins = State(initialValue: String(format: "%.1f", nutritionInfo.proteins))
        _carbs = State(initialValue: String(format: "%.1f", nutritionInfo.carbs))
        _fats = State(initialValue: String(format: "%.1f", nutritionInfo.fats))
        _fiber = State(initialValue: String(format: "%.1f", nutritionInfo.fiber))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("INFORMATIONS DE BASE")) {
                    TextField("Nom du plat", text: $foodName)
                }
                
                Section(header: Text("VALEURS NUTRITIONNELLES"), footer: Text("Ces valeurs sont des estimations basées sur l'analyse de l'image et peuvent varier.").font(.caption).foregroundColor(.secondary)) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Protéines")
                        Spacer()
                        TextField("0", text: $proteins)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Glucides")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Lipides")
                        Spacer()
                        TextField("0", text: $fats)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Fibres")
                        Spacer()
                        TextField("0", text: $fiber)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Ajouter au journal") {
                        addToJournal()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Résumé de l'analyse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addToJournal() {
        // Convertir les entrées textuelles en valeurs numériques
        guard let caloriesValue = Double(calories),
              let proteinsValue = Double(proteins),
              let carbsValue = Double(carbs),
              let fatsValue = Double(fats),
              let fiberValue = Double(fiber) else {
            // Gérer l'erreur si les conversions échouent
            return
        }
        
        // Créer un objet NutritionInfo
        let nutritionInfo = NutritionInfo(
            calories: caloriesValue,
            proteins: proteinsValue,
            carbs: carbsValue,
            fats: fatsValue,
            fiber: fiberValue
        )
        
        // Créer un Food
        let food = Food(
            id: UUID(),
            name: foodName,
            calories: Int(caloriesValue),
            proteins: proteinsValue,
            carbs: carbsValue,
            fats: fatsValue,
            fiber: fiberValue,
            servingSize: 1,
            servingUnit: .piece,
            image: nil
        )
        
        // Créer une entrée pour le journal
        let entry = FoodEntry(
            id: UUID(),
            food: food,
            quantity: 1,
            date: journalViewModel.selectedDate,
            mealType: mealType,
            source: .foodPhoto,
            unit: food.servingUnit.rawValue
        )
        
        // Enregistrer le scan dans l'historique
        let foodScan = FoodScan(
            foodName: foodName,
            nutritionInfo: nutritionInfo,
            date: Date(),
            mealType: mealType
        )
        LocalDataManager.shared.saveFoodScan(foodScan)
        
        // Ajouter l'entrée au journal
        journalViewModel.addFoodEntry(entry)
        
        // Fermer la vue
        dismiss()
        
        NotificationCenter.default.post(name: .dismissAllSheets, object: nil)
    }
}
