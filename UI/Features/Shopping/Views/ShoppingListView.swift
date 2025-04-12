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
    @State private var showingAddSheet = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(IngredientCategory.allCases, id: \.self) { category in
                        if let items = viewModel.shoppingItems[category], !items.isEmpty {
                            ShoppingSectionView(
                                title: category.rawValue,
                                items: items,
                                onToggle: { item in
                                    withAnimation {
                                        viewModel.toggleItemCheck(item: item)
                                    }
                                },
                                onDelete: { item in
                                    Task {
                                        await viewModel.deleteItem(item)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.bottom, 80) // Pour la TabBar custom
                .padding(.top, 20)
            }


            Button(action: {
                showingAddSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(AppTheme.primaryBlue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
            .sheet(isPresented: $showingAddSheet) {
                AddCustomShoppingItemSheet { name, quantity, unit, category in
                    Task {
                        await viewModel.addCustomItem(name: name, quantity: quantity, unit: unit, category: category)
                    }
                }
            }
        }
        .onAppear {
            viewModel.setDependencies(localDataManager: localDataManager)
            Task { await loadData() }
        }
    }

    private func loadData() async {
        do {
            let recipes = try await localDataManager.loadSelectedRecipes()
            viewModel.generateShoppingList(from: recipes)
        } catch {
            print("❌ Erreur: \(error)")
        }
        if let savedItems: [IngredientCategory: [ShoppingItem]] = try? await localDataManager.load(forKey: "custom_shopping_items") {
            viewModel.shoppingItems = savedItems
        }
    }

    private func formatQuantity(_ value: Double) -> String {
        if value == 0 { return "" }
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
        )
    }
}

struct ShoppingListWrapper: View {
    var isActive: Bool
    @EnvironmentObject private var localDataManager: LocalDataManager

    var body: some View {
        VStack {
            if isActive {
                ShoppingListView()
                    .environmentObject(localDataManager)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


struct ShoppingSectionView: View {
    let title: String
    let items: [ShoppingItem]
    let onToggle: (ShoppingItem) -> Void
    let onDelete: (ShoppingItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            ForEach(items) { item in
                HStack {
                    Button {
                        onToggle(item)
                    } label: {
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isChecked ? .green : .gray)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)

                    Text("\(Int(item.quantity)) \(item.unit)")
                        .bold()
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(item.isChecked ? .gray : .primary)

                    Text(item.name)
                        .strikethrough(item.isChecked)
                        .foregroundColor(item.isChecked ? .gray : .primary)

                    Spacer()
                }
                .contextMenu {
                    Button(role: .destructive) {
                        onDelete(item)
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
                .padding(.horizontal)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDelete(item) // 🔥 suppression
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
            }

        }
    }
}

