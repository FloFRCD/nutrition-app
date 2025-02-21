//
//  HomeView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI


struct HomeView: View {
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @State private var isNutritionExpanded = false
    
    var body: some View {
        ZStack { // Déplacer le ZStack en dehors du NavigationView
            NavigationView {
                ZStack {
                    // Contenu principal
                    ScrollView {
                        VStack(spacing: 15) { // Espacement uniforme entre les sections
                            DailyProgressView(
                                userProfile: localDataManager.userProfile,
                                isExpanded: $isNutritionExpanded
                            )
                            
                            // Next Meal Section
                            if let nextMeal = localDataManager.meals.first {
                                NextMealView(meal: nextMeal)
                            } else {
                                EmptyNextMealView()
                            }
                            
                            // Recent Scans Section
                            if !localDataManager.recentScans.isEmpty {
                                RecentScansView(scans: localDataManager.recentScans)
                            } else {
                                EmptyRecentScansView()
                            }
                        }
                        .padding(.horizontal) // Padding horizontal uniquement
                    }
                    .blur(radius: isNutritionExpanded ? 3 : 0)
                    .zIndex(0)
                }
                .navigationTitle("Bonjour \(localDataManager.userProfile?.name.components(separatedBy: " ").first ?? "")")
            }
            .zIndex(0)

            // Overlay sombre et vue expandée au-dessus de tout
            if isNutritionExpanded {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isNutritionExpanded = false
                        }
                    }
                
                // Vue expandée
                if let profile = localDataManager.userProfile {
                    GeometryReader { geometry in
                        ExpandedView(
                            needs: NutritionCalculator.shared.calculateNeeds(for: profile),
                            isExpanded: $isNutritionExpanded
                        )
                        .frame(width: geometry.size.width * 0.9)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.5)
                    }
                    .zIndex(2)
                }
            }
        }
    }
}


