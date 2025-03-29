//
//  ShoppingListView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject private var localDataManager: LocalDataManager
    @StateObject private var viewModel = ShoppingListViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Liste avec design amélioré
            List {
                ForEach(IngredientCategory.allCases, id: \.self) { category in
                    if let items = viewModel.shoppingItems[category], !items.isEmpty {
                        Section(header:
                            Text(category.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                        ) {
                            ForEach(items) { item in
                                HStack {
                                    // Checkbox pour marquer comme fait
                                    Button(action: {
                                        withAnimation {
                                            viewModel.toggleItemCheck(item: item)
                                        }
                                    }) {
                                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isChecked ? .green : .gray)
                                            .font(.system(size: 20))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    // Quantité et unité à gauche (inversé comme demandé)
                                    Text("\(formatQuantity(item.quantity)) \(item.unit)")
                                        .bold()
                                        .frame(width: 80, alignment: .leading)
                                        .foregroundColor(item.isChecked ? .gray : .primary)
                                    
                                    // Nom de l'ingrédient à droite
                                    Text(item.name)
                                        .strikethrough(item.isChecked)
                                        .foregroundColor(item.isChecked ? .gray : .primary)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.toggleItemCheck(item: item)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .onAppear {
            Task {
                await loadData()
            }
        }
    }
    
    // Méthode pour charger les données
    private func loadData() async {
        do {
            let recipes = try await localDataManager.loadSelectedRecipes()
            viewModel.generateShoppingList(from: recipes)
        } catch {
            print("❌ Erreur: \(error)")
        }
    }
    
    // Formater les quantités
    private func formatQuantity(_ value: Double) -> String {
        if value == 0 {
            return ""
        } else if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// Ajouter cette structure en dehors de PlanningView
struct ShoppingListWrapper: View {
    var isActive: Bool
    @EnvironmentObject private var localDataManager: LocalDataManager
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        VStack {
            if isActive {
                ShoppingListView()
                    .environmentObject(localDataManager)
                    .id(refreshTrigger) // Forcer le rechargement complet
                    .onAppear {
                        // Forcer un rafraîchissement quand la vue devient active
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            refreshTrigger = UUID()
                        }
                    }
            } else {
                // Vue placeholder pour l'onglet inactif
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: isActive) { wasActive, isNowActive in
            if isNowActive {
                print("🔄 ShoppingListWrapper devient active")
                // Déclencher un rafraîchissement avec délai pour assurer que toutes les propriétés sont initialisées
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    refreshTrigger = UUID()
                }
            }
        }
    }
}
