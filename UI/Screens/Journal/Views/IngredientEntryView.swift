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
    
    @State private var ingredients: [IngredientEntry] = []
    @State private var isProcessing = false
    @State private var isShowingCIQUALSearch = false
    @State private var selectedIngredientIndex: Int? = nil
    
    
    struct IngredientEntry: Identifiable {
        let id = UUID()
        var name: String = ""
        var quantity: String = ""
        var ciqualId: String? = nil
        var nutritionInfo: NutritionValues? = nil
    }
    
    var body: some View {
        NavigationView {
            mainContent
        }
    }
    
    // MARK: - Sous-vues
    
    private var mainContent: some View {
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
        .sheet(isPresented: $isShowingCIQUALSearch) {
            NavigationView {
                CIQUALFoodSearchView { ciqualFood, quantity in
                    addCiqualFood(ciqualFood, quantity: quantity)
                }
                .environmentObject(nutritionService)
            }
        }
    }
    
    private var ingredientsSection: some View {
        Section(header: Text("INGRÉDIENTS")) {
            if ingredients.isEmpty {
                emptyIngredientsView
            } else {
                ingredientsList
            }
            
            addButton
        }
    }
    
    private var emptyIngredientsView: some View {
        Text("Aucun ingrédient ajouté")
            .foregroundColor(.secondary)
            .italic()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    private var ingredientsList: some View {
        ForEach(ingredients.indices, id: \.self) { index in
            ingredientRow(at: index)
        }
    }
    
    private func ingredientRow(at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ingredients[index].name)
                    .font(.headline)
                
                Spacer()
                
                TextField("Qté", text: Binding(
                    get: { ingredients[index].quantity },
                    set: { ingredients[index].quantity = $0 }
                ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .padding(.horizontal, 4)
                .background(Color(.systemGray6))
                .cornerRadius(4)
                
                Text("g")
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
            
            if let nutrition = ingredients[index].nutritionInfo,
               let quantity = Double(ingredients[index].quantity) {
                nutritionRow(nutrition: nutrition, quantity: quantity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 2, x: 0, y: 1)
        .padding(.vertical, 2)
    }
    
    private func nutritionRow(nutrition: NutritionValues, quantity: Double) -> some View {
        let ratio = quantity / 100.0
        
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
    
    private var addButton: some View {
        Button {
            isShowingCIQUALSearch = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                Text("Ajouter un aliment")
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(BorderedButtonStyle())
    }
    
    private var nutritionSummarySection: some View {
        Section(header: Text("RÉSUMÉ NUTRITIONNEL")) {
            HStack {
                nutritionSummaryItem(
                    title: "Calories",
                    value: "\(Int(totalNutrition.calories))",
                    unit: "kcal",
                    color: .orange
                )
                
                nutritionSummaryItem(
                    title: "Protéines",
                    value: String(format: "%.1f", totalNutrition.proteins),
                    unit: "g",
                    color: .blue
                )
                
                nutritionSummaryItem(
                    title: "Glucides",
                    value: String(format: "%.1f", totalNutrition.carbohydrates),
                    unit: "g",
                    color: .green
                )
                
                nutritionSummaryItem(
                    title: "Lipides",
                    value: String(format: "%.1f", totalNutrition.fats),
                    unit: "g",
                    color: .red
                )
            }
            .padding(.vertical, 8)
        }
    }
    
    private func nutritionSummaryItem(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
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
                Button {
                    submitIngredients()
                } label: {
                    Text("Ajouter au journal")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .bold()
                }
                .disabled(ingredients.isEmpty)
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
    }
    
    // MARK: - Méthodes privées
    
    private var totalNutrition: NutritionValues {
        var calories: Double = 0
        var proteins: Double = 0
        var carbs: Double = 0
        var fats: Double = 0
        var fiber: Double = 0
        
        for ingredient in ingredients {
            if let nutrition = ingredient.nutritionInfo,
               let quantity = Double(ingredient.quantity) {
                let ratio = quantity / 100.0
                
                calories += nutrition.calories * ratio
                proteins += nutrition.proteins * ratio
                carbs += nutrition.carbohydrates * ratio
                fats += nutrition.fats * ratio
                fiber += nutrition.fiber * ratio
            }
        }
        
        return NutritionValues(
            calories: calories,
            proteins: proteins,
            carbohydrates: carbs,
            fats: fats,
            fiber: fiber
        )
    }
    
    private func addCiqualFood(_ ciqualFood: CIQUALFood, quantity: Double) {
        withAnimation {
            let nutritionValues = NutritionValues(
                calories: ciqualFood.energie_kcal ?? 0,
                proteins: ciqualFood.proteines ?? 0,
                carbohydrates: ciqualFood.glucides ?? 0,
                fats: ciqualFood.lipides ?? 0,
                fiber: ciqualFood.fibres ?? 0
            )
            
            ingredients.append(IngredientEntry(
                name: ciqualFood.nom,
                quantity: String(format: "%.1f", quantity),
                ciqualId: ciqualFood.id,
                nutritionInfo: nutritionValues
            ))
        }
    }
    
    private func submitIngredients() {
        guard !ingredients.isEmpty else { return }
        
        isProcessing = true
        
        // Ajouter chaque ingrédient CIQUAL au journal via NutritionService
        for ingredient in ingredients {
            if let ciqualId = ingredient.ciqualId,
               let quantity = Double(ingredient.quantity) {
                nutritionService.addCIQUALFoodToJournal(
                    ciqualFoodId: ciqualId,
                    quantity: quantity,
                    mealType: mealType
                )
            }
        }
        
        // Notifier pour fermer la vue
        onIngredientsSubmitted([:])
        
        // Fermer la vue après un court délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// Vue de recherche CIQUAL
struct CIQUALFoodSearchView: View {
    @EnvironmentObject var nutritionService: NutritionService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var searchResults: [CIQUALFood] = []
    @State private var quantity: String = "100"
    @State private var isLoading = false
    
    var onFoodSelected: (CIQUALFood, Double) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Barre de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Rechercher un aliment", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: searchText) { newValue in
                        if !newValue.isEmpty && newValue.count >= 2 {
                            isLoading = true
                            // Délai pour éviter trop de recherches pendant la frappe
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if searchText == newValue { // Vérifie si le texte n'a pas changé depuis
                                    searchResults = nutritionService.searchCIQUALFoods(query: newValue)
                                    isLoading = false
                                }
                            }
                        } else {
                            searchResults = []
                            isLoading = false
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Résultats de recherche ou messages informatifs
            ZStack {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Recherche en cours...")
                        Spacer()
                    }
                } else if searchResults.isEmpty && !searchText.isEmpty && searchText.count >= 2 {
                    VStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucun résultat pour \"\(searchText)\"")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if searchText.count < 2 && !searchText.isEmpty {
                    VStack {
                        Spacer()
                        Text("Entrez au moins 2 caractères")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if searchText.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Recherchez un aliment dans la base CIQUAL")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    // Liste des résultats
                    List {
                        ForEach(searchResults) { food in
                            FoodResultRow(food: food, quantity: $quantity) { qty in
                                onFoodSelected(food, qty)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Base CIQUAL")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear {
            nutritionService.loadCIQUALDatabase()
        }
    }
}


struct FoodResultRow: View {
    let food: CIQUALFood
    @Binding var quantity: String
    let onSelect: (Double) -> Void
    
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Nom de l'aliment
            Text(food.nom)
                .font(.headline)
                .lineLimit(2)
            
            // Valeurs nutritionnelles résumées
            HStack(spacing: 12) {
                Text("\(Int(food.energie_kcal ?? 0)) kcal")
                    .foregroundColor(.orange)
                
                Text("P: \(String(format: "%.1f", food.proteines ?? 0))g")
                    .foregroundColor(.blue)
                
                Text("G: \(String(format: "%.1f", food.glucides ?? 0))g")
                    .foregroundColor(.green)
                
                Text("L: \(String(format: "%.1f", food.lipides ?? 0))g")
                    .foregroundColor(.red)
            }
            .font(.caption)
            .padding(.vertical, 2)
            
            // Sélecteur de quantité et bouton d'ajout
            HStack {
                Spacer()
                
                // Champ de quantité
                TextField("100", text: $quantity)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onTapGesture {
                        isEditing = true
                    }
                
                Text("g")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
                
                // Bouton d'ajout
                Button(action: {
                    if let qty = Double(quantity), qty > 0 {
                        onSelect(qty)
                    } else {
                        // Utiliser 100g par défaut si la quantité n'est pas valide
                        onSelect(100)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            // Option: sélectionner cet élément quand on tape dessus
            if !isEditing {
                if let qty = Double(quantity), qty > 0 {
                    onSelect(qty)
                } else {
                    onSelect(100)
                }
            }
        }
    }
}
