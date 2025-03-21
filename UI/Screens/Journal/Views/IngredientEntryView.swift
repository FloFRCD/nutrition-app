//
//  IngredientEntryView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import SwiftUI

import SwiftUI

struct IngredientEntryView: View {
    let mealType: MealType
    let onIngredientsSubmitted: ([String: Double]) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var ingredients: [IngredientEntry] = [IngredientEntry()]
    @State private var isProcessing = false
    
    struct IngredientEntry: Identifiable {
        let id = UUID()
        var name: String = ""
        var quantity: String = ""
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingrédients")) {
                    // Utilisation de indices pour éviter les problèmes potentiels
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
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
                            
                            // Bouton de suppression pour tous sauf le premier ingrédient
                            if ingredients.count > 1 {
                                Button {
                                    // Action de suppression sécurisée
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
                    }
                    
                    // Bouton pour ajouter un ingrédient
                    Button {
                        withAnimation {
                            ingredients.append(IngredientEntry())
                        }
                    } label: {
                        Label("Ajouter un ingrédient", systemImage: "plus.circle.fill")
                            .foregroundColor(.green)
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
        }
    }
    
    private var isValid: Bool {
        for ingredient in ingredients {
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
            if let quantity = Double(ingredient.quantity), !ingredient.name.isEmpty {
                result[ingredient.name] = quantity
            }
        }
        
        return result
    }
}
