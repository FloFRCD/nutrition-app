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
    
    // Utiliser une approche à deux états au lieu d'un simple boolean
    @State private var viewState: ViewState = .initial
    
    // Utiliser une enum pour représenter tous les états possibles de la vue
    enum ViewState {
        case initial       // Premier chargement, jamais chargé
        case loading       // Chargement en cours
        case empty         // Chargement terminé, aucun élément
        case loaded        // Chargement terminé, éléments disponibles
    }
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Liste de courses")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Actualiser") {
                            refreshList()
                        }
                        .disabled(viewState == .loading)
                    }
                }
                // Utiliser une seule task pour le chargement initial
                .task {
                    // Ne charger que si c'est la première fois
                    if viewState == .initial {
                        await loadShoppingList()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RecipeSelectionChanged"))) { _ in
                    refreshList()
                }
        }
    }
    
    // Vue conditionnelle basée sur l'état
    @ViewBuilder
    private var contentView: some View {
        switch viewState {
        case .initial, .loading:
            ProgressView("Chargement des ingrédients...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        case .empty:
            ContentUnavailableView(
                "Liste de courses vide",
                systemImage: "cart",
                description: Text("Sélectionnez des recettes pour générer votre liste de courses")
            )
            
        case .loaded:
            shoppingListContent
        }
    }
    
    // Fonction pour rafraîchir la liste
    private func refreshList() {
        // Ne pas déclencher de chargement si déjà en cours
        guard viewState != .loading else { return }
        
        Task {
            await loadShoppingList()
        }
    }
    
    // Contenu de la liste de courses
    private var shoppingListContent: some View {
        List {
            ForEach(IngredientCategory.allCases, id: \.self) { category in
                if let items = viewModel.shoppingItems[category], !items.isEmpty {
                    Section(header: Text(category.rawValue)) {
                        ForEach(items) { item in
                            shoppingItemRow(item: item)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        // Utiliser une animation plus douce pour les transitions
        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
    }
    
    // Ligne pour un élément de la liste
    private func shoppingItemRow(item: ShoppingItem) -> some View {
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.toggleItemCheck(item: item)
                }
            }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .green : .gray)
            }
            .buttonStyle(BorderlessButtonStyle()) // Pour éviter les problèmes dans la List
            
            Text("\(formatQuantity(item.quantity)) \(item.unit)")
                .bold()
                .frame(width: 80, alignment: .leading)
            
            Text(item.name)
                .strikethrough(item.isChecked)
                .foregroundColor(item.isChecked ? .gray : .primary)
        }
        .contentShape(Rectangle()) // Pour rendre toute la ligne cliquable
        .onTapGesture {
            withAnimation {
                viewModel.toggleItemCheck(item: item)
            }
        }
    }
    
    // Version optimisée avec gestion des états claire et séquencée
    private func loadShoppingList() async {
        // Passer en état de chargement dès le début
        await MainActor.run {
            viewState = .loading
        }
        
        do {
            // Petite pause pour assurer la stabilité de l'UI
            try await Task.sleep(for: .milliseconds(300))
            
            // Charger les recettes
            let selectedRecipes = try await localDataManager.loadSelectedRecipes()
            
            // Générer la liste sans aller sur le thread principal
            viewModel.generateShoppingList(from: selectedRecipes)
            
            // Déterminer l'état final après une courte pause
            try await Task.sleep(for: .milliseconds(100))
            
            await MainActor.run {
                // Déterminer l'état approprié
                if viewModel.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded
                }
                
                print("✅ Liste de courses générée à partir de \(selectedRecipes.count) recettes")
            }
        } catch {
            print("❌ Erreur lors du chargement des recettes: \(error)")
            
            await MainActor.run {
                // En cas d'erreur, vérifier si la liste est vide
                viewState = viewModel.isEmpty ? .empty : .loaded
            }
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
