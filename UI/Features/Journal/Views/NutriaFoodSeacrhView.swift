//
//  NutriaFoodSeacrhView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 22/04/2025.
//

import SwiftUI
import FirebaseFirestore

struct NutriaFoodSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var nutritionService: NutritionService

    @State private var searchText = ""
    @State private var isPresentingCreationSheet = false
    @State private var allFoods: [NutriaFood] = []
    @State private var isLoading = true

    let onFoodSelected: (NutriaFood, Double, ServingUnit) -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    searchBar
                    foodListView
                }

                Button(action: {
                    isPresentingCreationSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.vibrantGreen)
                        .shadow(radius: 5)
                }
                .padding()
                .accessibilityLabel("Créer un aliment")
                .sheet(isPresented: $isPresentingCreationSheet) {
                    NutriaFoodCreationSheet { newFood, qty, unit in
                        onFoodSelected(newFood, qty, unit)
                        isPresentingCreationSheet = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .environmentObject(nutritionService)
                }
            }
            .navigationTitle("Rechercher un aliment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .task {
                allFoods = await nutritionService.loadAllFoods()
                isLoading = false
            }
        }
    }

    var searchBar: some View {
        TextField("Rechercher un aliment...", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }

    @ViewBuilder
    var foodListView: some View {
        if isLoading {
            loadingView
        } else if filteredFoods.isEmpty {
            emptyStateView
        } else {
            resultsListView
        }
    }

    var loadingView: some View {
        ProgressView("Chargement...")
    }

    var emptyStateView: some View {
        Text("Aucun aliment trouvé")
            .foregroundColor(.gray)
            .italic()
    }

    var resultsListView: some View {
        List(filteredFoods.indices, id: \.self) { index in
            let food = filteredFoods[index]
            
            HStack {
                VStack(alignment: .leading) {
                    Text(food.canonicalName).bold()
                    Text("Calories : \(Int(food.calories)) kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(Int(food.servingSize)) \(ServingUnit(rawValue: food.servingUnit)?.displayName ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .onTapGesture {
                if let unit = ServingUnit(rawValue: food.servingUnit) {
                    onFoodSelected(food, food.servingSize, unit)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .listStyle(.plain)
    }



    var filteredFoods: [NutriaFood] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allFoods
        }
        return allFoods.filter {
            $0.canonicalName.lowercased().contains(searchText.lowercased())
        }
    }
}


struct NutriaFoodCreationSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nutritionService: NutritionService

    // Champs utilisateur
    @State private var foodName: String = ""
    @State private var brand: String? = nil
    @State private var quantity: Double = 1
    @State private var unit: ServingUnit = .gram

    // UI
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    let onFoodCreated: (NutriaFood, Double, ServingUnit) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Nom de l’aliment", text: $foodName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Marque (facultatif)", text: Binding(
                    get: { brand ?? "" },
                    set: { brand = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Quantité", value: $quantity, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Picker("Unité", selection: $unit) {
                    Text("g").tag(ServingUnit.gram)
                    Text("mL").tag(ServingUnit.milliliter)
                    Text("pièce").tag(ServingUnit.piece)
                }
                .pickerStyle(.segmented)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Générer l’aliment avec l’IA") {
                    generateFood()
                }
                .disabled(isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("Créer un aliment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    func generateFood() {
        Task {
            isLoading = true
            errorMessage = nil

            // ✅ Applique la règle de quantité minimale pour g ou mL
            if unit == .gram || unit == .milliliter {
                quantity = max(quantity, 100)
            }

            if let newFood = await nutritionService.generateNutriaFoodIfMissing(
                name: foodName,
                brand: brand,
                unit: unit,
                size: quantity
            ) {
                onFoodCreated(newFood, quantity, unit)
                dismiss()
            } else {
                errorMessage = "❌ Impossible de générer cet aliment."
            }

            isLoading = false
        }
    }
}



