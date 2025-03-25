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
    
    @State private var ingredients: [IngredientEntry] = [IngredientEntry()]
    @State private var isProcessing = false
    @State private var isShowingCIQUALSearch = false
    @State private var selectedIngredientIndex: Int? = nil
    
    struct IngredientEntry: Identifiable {
        let id = UUID()
        var name: String = ""
        var quantity: String = ""
        var ciqualId: String? = nil // Ajout d'un ID CIQUAL pour référence
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingrédients")) {
                    // Liste des ingrédients
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            if ingredients[index].ciqualId != nil {
                                // Affichage spécial pour les ingrédients CIQUAL
                                Text(ingredients[index].name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(ingredients[index].quantity) g")
                                    .foregroundColor(.secondary)
                            } else {
                                // Entrée manuelle d'ingrédient
                                TextField("Ingrédient", text: Binding(
                                    get: { ingredients[index].name },
                                    set: { ingredients[index].name = $0 }
                                ))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                
                                Divider()
                                
                                TextField("Qté (g)", text: Binding(
                                    get: { ingredients[index].quantity },
                                    set: { ingredients[index].quantity = $0 }
                                ))
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            }
                            
                            // Bouton de suppression
                            if ingredients.count > 1 {
                                Button {
                                    if ingredients.indices.contains(index) {
                                        withAnimation {
                                            ingredients.remove(at: index)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .contextMenu {
                            // Option pour remplacer par un ingrédient CIQUAL
                            if ingredients[index].ciqualId == nil {
                                Button {
                                    selectedIngredientIndex = index
                                    isShowingCIQUALSearch = true
                                } label: {
                                    Label("Rechercher dans CIQUAL", systemImage: "magnifyingglass")
                                }
                            }
                        }
                    }
                    
                    // Boutons d'ajout d'ingrédients
                    HStack {
                        // Bouton d'ajout manuel
                        Button {
                            withAnimation {
                                ingredients.append(IngredientEntry())
                            }
                        } label: {
                            Label("Ajouter manuellement", systemImage: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        
                        Divider()
                        
                        // Bouton de recherche CIQUAL
                        Button {
                            selectedIngredientIndex = ingredients.count
                            withAnimation {
                                ingredients.append(IngredientEntry())
                            }
                            isShowingCIQUALSearch = true
                        } label: {
                            Label("Base CIQUAL", systemImage: "magnifyingglass")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section {
                    if isProcessing {
                        HStack {
                            Spacer()
                            ProgressView("Analyse en cours...")
                            Spacer()
                        }
                    } else {
                        Button {
                            let ingredientDict = processIngredients()
                            if !ingredientDict.isEmpty {
                                isProcessing = true
                                onIngredientsSubmitted(ingredientDict)
                            }
                        } label: {
                            Text("Analyser et ajouter au journal")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .disabled(!isValid)
                    }
                } footer: {
                    Text("Notre IA analysera les ingrédients pour déterminer les valeurs nutritionnelles")
                }
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
            .sheet(isPresented: $isShowingCIQUALSearch) {
                NavigationView {
                    CIQUALFoodSearchView { ciqualFood, quantity in
                        // Si un index est sélectionné et qu'il est valide
                        if let index = selectedIngredientIndex, ingredients.indices.contains(index) {
                            ingredients[index] = IngredientEntry(
                                name: ciqualFood.nom,
                                quantity: String(format: "%.1f", quantity),
                                ciqualId: ciqualFood.id
                            )
                        }
                    }
                    .environmentObject(nutritionService)
                }
            }
        }
    }
    
    private var isValid: Bool {
        for ingredient in ingredients {
            // Si c'est un ingrédient CIQUAL, il est déjà valide
            if ingredient.ciqualId != nil {
                continue
            }
            
            // Sinon on vérifie les champs manuels
            if ingredient.name.isEmpty || ingredient.quantity.isEmpty {
                return false
            }
            if Double(ingredient.quantity) == nil {
                return false
            }
        }
        return true
    }
    
    private func processIngredients() -> [String: Double] {
        var result: [String: Double] = [:]
        
        for ingredient in ingredients {
            // Pour les ingrédients CIQUAL, on peut les traiter directement
            if let ciqualId = ingredient.ciqualId, let quantity = Double(ingredient.quantity) {
                // Vous pourriez ajouter directement l'aliment CIQUAL au journal ici
                nutritionService.addCIQUALFoodToJournal(
                    ciqualFoodId: ciqualId,
                    quantity: quantity,
                    mealType: mealType
                )
            }
            // Pour les ingrédients manuels, on procède comme avant
            else if let quantity = Double(ingredient.quantity), !ingredient.name.isEmpty {
                result[ingredient.name] = quantity
            }
        }
        
        return result
    }
}

// Vue de recherche CIQUAL
struct CIQUALFoodSearchView: View {
    @EnvironmentObject var nutritionService: NutritionService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var searchResults: [CIQUALFood] = []
    @State private var quantity: String = "100"
    
    var onFoodSelected: (CIQUALFood, Double) -> Void
    
    var body: some View {
        VStack {
            // Barre de recherche
            HStack {
                TextField("Rechercher un aliment", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: searchText) { newValue in
                        if !newValue.isEmpty {
                            searchResults = nutritionService.searchCIQUALFoods(query: newValue)
                        } else {
                            searchResults = []
                        }
                    }
                
                Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // Résultats de recherche
            if searchResults.isEmpty && !searchText.isEmpty {
                Text("Aucun résultat pour \"\(searchText)\"")
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(searchResults) { food in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(food.nom)
                                    .font(.headline)
                                
                                HStack {
                                    Text("\(Int(food.energie_kcal ?? 0)) kcal")
                                    Text("•")
                                    Text("P: \(String(format: "%.1f", food.proteines ?? 0))g")
                                    Text("•")
                                    Text("G: \(String(format: "%.1f", food.glucides ?? 0))g")
                                    Text("•")
                                    Text("L: \(String(format: "%.1f", food.lipides ?? 0))g")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack {
                                TextField("100", text: $quantity)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50)
                                    .multilineTextAlignment(.trailing)
                                
                                Text("g")
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    if let qty = Double(quantity) {
                                        onFoodSelected(food, qty)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Base CIQUAL")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            nutritionService.loadCIQUALDatabase()
        }
    }
}
