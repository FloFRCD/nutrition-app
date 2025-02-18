//
//  MainTabView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Planning") // À remplacer par PlanningView
                .tabItem {
                    Label("Planning", systemImage: "calendar")
                }
            
            Text("Repas") // À remplacer par MealView
                .tabItem {
                    Label("Repas", systemImage: "fork.knife")
                }
            
            Text("Progrès") // À remplacer par ProgressView
                .tabItem {
                    Label("Progrès", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            Text("Profil") // À remplacer par ProfileView
                .tabItem {
                    Label("Profil", systemImage: "person.circle")
                }
        }
    }
}
