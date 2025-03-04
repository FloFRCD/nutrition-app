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
            if #available(iOS 18.0, *) {
                HomeView()
                    .tabItem {
                        Label("Accueil", systemImage: "house.fill")
                    }
            } else {
                // Fallback on earlier versions
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
    
    private func createUserProfile() -> UserProfile {
        return UserProfile(
            name: "Florian",
            age: 30,
            gender: .male,
            height: 180,
            weight: 80,
            fitnessGoal: .loseWeight, // Utilisez la bonne valeur de votre enum FitnessGoal
            activityLevel: .moderatelyActive   // Utilisez la bonne valeur de votre enum ActivityLevel
        )
    }
}
