//
//  MainTabView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
            
            ScanView()
                .tabItem {
                    Label("Scanner", systemImage: "camera.fill")
                }
            
            PlanningView()
                .tabItem {
                    Label("Planning", systemImage: "calendar")
                }
            
            ShoppingListView()
                .tabItem {
                    Label("Courses", systemImage: "cart.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
    }
}
