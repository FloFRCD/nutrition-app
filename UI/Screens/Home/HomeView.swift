//
//  HomeView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI


@available(iOS 18.0, *)
struct HomeView: View {
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @State private var isNutritionExpanded = false
    
    // Ajout des états pour le défilement automatique
    @State private var scrollPosition: SwiftUI.ScrollPosition = .init()
    @State private var currentScrollOffset: CGFloat = 0
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    @State private var initialAnimation: Bool = false
    @State private var isUserInteracting: Bool = false
    @State private var scrollPhase: ScrollPhase = .idle
    @State private var userSelectedStatIndex: Int? = nil
    
    var body: some View {
        ZStack { // Déplacer le ZStack en dehors du NavigationView
            NavigationView {
                ZStack {
                    // Contenu principal
                    ScrollView {
                        VStack(spacing: 15) { // Espacement uniforme entre les sections
                            DailyProgressView(
                                userProfile: localDataManager.userProfile,
                                isExpanded: $isNutritionExpanded,
                                scrollPosition: $scrollPosition,
                                initialAnimation: initialAnimation,
                                isUserInteracting: $isUserInteracting,
                                userSelectedStatIndex: $userSelectedStatIndex,
                                currentScrollOffset: $currentScrollOffset
                            )
                            
                            // Next Meal Section
                            if let nextMeal = localDataManager.meals.first {
                                NextMealView(meal: nextMeal)
                            } else {
                                EmptyNextMealView()
                            }
                            
                            // Recent Scans Section
//                            if !localDataManager.recentScans.isEmpty {
//                                RecentScansView(scans: localDataManager.recentScans)
//                            } else {
//                                EmptyRecentScansView()
//                            }
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
        // À la fin de votre ZStack principal, avant les dernières accolades
        .onReceive(timer) { _ in
            currentScrollOffset += 0.15
            scrollPosition.scrollTo(x: currentScrollOffset)
        }
        .task {
            // Animation d'entrée après un court délai
            try? await Task.sleep(for: .seconds(0.35))
            
            withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                initialAnimation = true
            }
        }
    }
}


