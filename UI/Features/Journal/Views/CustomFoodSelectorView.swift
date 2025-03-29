//
//  CustomFoodSelectorView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 29/03/2025.
//

import Foundation
import SwiftUI

struct CustomFoodSelectorView: View {
    @EnvironmentObject var nutritionService: NutritionService
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var quantity: String = "100"
    
    var onFoodSelected: (CustomFood, Double) -> Void
    
    // Filtrer les aliments personnalisés en fonction de la recherche
    private var filteredFoods: [CustomFood] {
        if searchText.isEmpty {
            return nutritionService.customFoods
        } else {
            return nutritionService.customFoods.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Barre de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Rechercher un aliment personnalisé", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
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
            
            if filteredFoods.isEmpty {
                VStack {
                    Spacer()
                    if searchText.isEmpty {
                        Image(systemName: "star.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucun aliment personnalisé enregistré")
                            .foregroundColor(.secondary)
                        Text("Créez des aliments via le bouton 'Personnalisé'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucun résultat pour \"\(searchText)\"")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredFoods) { food in
                        CustomFoodRow(food: food, quantity: $quantity) { qty in
                            onFoodSelected(food, qty)
                            dismiss()
                        }
                    }
                    .onDelete { indexSet in
                        // Supprimer les aliments personnalisés
                        for index in indexSet {
                            let food = filteredFoods[index]
                            nutritionService.removeCustomFood(id: food.id)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Mes aliments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .destructiveAction) {
                EditButton()
            }
        }
        .onAppear {
            nutritionService.loadCustomFoods()
        }
    }
}

struct CustomFoodRow: View {
    let food: CustomFood
    @Binding var quantity: String
    let onSelect: (Double) -> Void
    
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Nom de l'aliment
            Text(food.name)
                .font(.headline)
                .lineLimit(2)
            
            // Valeurs nutritionnelles résumées
            HStack(spacing: 12) {
                Text("\(food.calories) kcal")
                    .foregroundColor(.orange)
                
                Text("P: \(String(format: "%.1f", food.proteins))g")
                    .foregroundColor(.blue)
                
                Text("G: \(String(format: "%.1f", food.carbs))g")
                    .foregroundColor(.green)
                
                Text("L: \(String(format: "%.1f", food.fats))g")
                    .foregroundColor(.red)
            }
            .font(.caption)
            .padding(.vertical, 2)
            
            // Sélecteur de quantité et bouton d'ajout
            HStack {
                Text("Pour \(String(format: "%.0f", food.servingSize)) \(food.servingUnit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
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
