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
            // Si la nutrition est étendue, afficher la vue détaillée par-dessus
                       if isNutritionExpanded, let profile = localDataManager.userProfile {
                           ZStack {
                               Color.black.opacity(0.3)
                                   .ignoresSafeArea()
                                   .onTapGesture {
                                       withAnimation {
                                           isNutritionExpanded = false
                                       }
                                   }
                               
                               ExpandedView(
                                   needs: NutritionCalculator.shared.calculateNeeds(for: profile),
                                   isExpanded: $isNutritionExpanded
                               )
                               .padding()
                               .background(Color(.systemBackground))
                               .cornerRadius(20)
                               .shadow(radius: 10)
                               .padding(.horizontal)
                           }
                           .transition(.opacity)
                           .zIndex(1)
                       }
                   }
               }
           }


