//
//  ShoppingListView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

// ShoppingListView.swift
import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                HStack {
                    Button(action: {
                        viewModel.toggleItem(item)
                    }) {
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(item.name)
                        .strikethrough(item.isChecked)
                    
                    Spacer()
                    
                    Text("\(item.quantity, specifier: "%.0f") \(item.unit)")
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: viewModel.removeItems)
        }
        .navigationTitle("Liste de courses")
        .toolbar {
            Button("Ajouter") {
                viewModel.showingAddItem = true
            }
        }
        .sheet(isPresented: $viewModel.showingAddItem) {
            // Formulaire d'ajout à implémenter
        }
    }
}


