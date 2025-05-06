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
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                ZStack {
                    Color(.systemBackground)
                        .opacity(0.3)
                        .blur(radius: 16) // effet flou visible
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
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
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == tab.index ? Color.black : Color.gray)

                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(selectedTab == tab.index ? .semibold : .regular)
                    .foregroundColor(selectedTab == tab.index ? Color.black : Color.gray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}


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
