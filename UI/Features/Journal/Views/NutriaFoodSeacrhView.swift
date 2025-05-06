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
                VStack(spacing: 0) {
                    searchBar
                    foodListView
                }
                Button(action: {
                    isPresentingCreationSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Ajouter un nouvel aliment")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(AppTheme.vibrantGreen)
                    .cornerRadius(30)
                    .shadow(radius: 5)
                }
                .padding()
                .accessibilityLabel("Créer un nouvel aliment personnalisé")
                .sheet(isPresented: $isPresentingCreationSheet) {
                    NutriaFoodCreationSheet { newFood, qty, unit in
                        onFoodSelected(newFood, qty, unit)
                        isPresentingCreationSheet = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .environmentObject(nutritionService)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Rechercher un aliment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.vibrantGreen)
                }
            }
            .task {
                allFoods = await nutritionService.loadAllFoods()
                isLoading = false
            }
        }
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Rechercher un aliment...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .submitLabel(.search)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding([.horizontal, .top])
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
        VStack {
            Spacer()
            ProgressView("Chargement...")
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.vibrantGreen))
            Spacer()
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Aucun aliment trouvé")
                .foregroundColor(.gray)
                .italic()
            Spacer()
        }
    }
    
    var resultsListView: some View {
        List(filteredFoods.indices, id: \.self) { index in
            let food = filteredFoods[index]

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.canonicalName)
                        .font(.body)
                        .foregroundColor(.primary)

                    if let desc = food.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    Text("Calories : \(Int(food.calories)) kcal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(Int(food.servingSize)) \(ServingUnit(rawValue: food.servingUnit)?.displayName ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
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

    @State private var foodName: String = ""
    @State private var brand: String? = nil
    @State private var quantity: Double = 100 // 100g par défaut
    @State private var unit: ServingUnit = .gram
    @State private var additionalDetails: String = ""
    @State private var showAdditionalDetails = false

    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    let onFoodCreated: (NutriaFood, Double, ServingUnit) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Génère ce que tu veux avec notre IA")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)

                    TextField("Nom de l’aliment", text: $foodName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    TextField("Marque (facultatif)", text: Binding(
                        get: { brand ?? "" },
                        set: { brand = $0.isEmpty ? nil : $0 }
                    ))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    HStack(spacing: 12) {
                        TextField("Quantité", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        Picker("Unité", selection: $unit) {
                            Text("g").tag(ServingUnit.gram)
                            Text("mL").tag(ServingUnit.milliliter)
                            Text("pièce").tag(ServingUnit.piece)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: unit) { newUnit in
                            switch newUnit {
                            case .gram, .milliliter:
                                quantity = 100
                            case .piece:
                                quantity = 1
                            }
                        }
                    }

                    DisclosureGroup("Ajouter des précisions pour l’IA", isExpanded: $showAdditionalDetails) {
                        TextEditor(text: $additionalDetails)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4))
                            )
                            .padding(.top, 8)
                    }
                    .font(.subheadline)
                    .accentColor(AppTheme.vibrantGreen)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: generateFood) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.vibrantGreen))
                        } else {
                            Text("Générer")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.vibrantGreen)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isLoading)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Créer un aliment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(AppTheme.vibrantGreen)
                }
            }
        }
    }

    func generateFood() {
        Task {
            isLoading = true
            errorMessage = nil

            if let newFood = await nutritionService.generateNutriaFoodIfMissing(
                name: foodName,
                brand: brand,
                unit: unit,
                size: quantity,
                additionalDetails: additionalDetails
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






