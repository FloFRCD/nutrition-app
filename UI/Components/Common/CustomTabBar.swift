//
//  CustomTabBar.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 30/03/2025.
//

import Foundation
import SwiftUI


struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var isTabBarVisible: Bool
    
    // Liste des options de la TabBar
    private let tabs = [
        TabItem(title: "Accueil", icon: "house.fill", index: 0),
        TabItem(title: "Journal", icon: "newspaper", index: 1),
        TabItem(title: "Recettes", icon: "line.3.horizontal", index: 2)
    ]
    
    var body: some View {
        if isTabBarVisible {
            HStack(spacing: 0) {
                ForEach(tabs, id: \.index) { tab in
                    tabButton(tab: tab)
                }
            }
            .padding(.vertical, 10) // Réduction de la hauteur
            .padding(.horizontal, 12)
            .background(
                // Fond plus léger
                ZStack {
                    AppTheme.tabBarGradient.opacity(0.5)
                        .background(.ultraThinMaterial)
                }
                
                    .cornerRadius(30)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            .padding(.horizontal, 40)
            .padding(.bottom, 20) // Réduction de l'espace en bas
        }
    }
    
    private func tabButton(tab: TabItem) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab.index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20)) // Légèrement plus petit
                    .foregroundColor(selectedTab == tab.index ? AppTheme.vibrantGreen  : Color.gray)
                
                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(selectedTab == tab.index ? .semibold : .regular)
                    .foregroundColor(selectedTab == tab.index ? Color.black : Color.gray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // Pour agrandir la zone tactile
        }
    }
}

// Modèle de données pour les éléments de la TabBar
struct TabItem {
    let title: String
    let icon: String
    let index: Int
}

class TabBarSettings: ObservableObject {
    @Binding var isVisible: Bool
    
    init(isVisible: Binding<Bool>) {
        self._isVisible = isVisible
    }
}
