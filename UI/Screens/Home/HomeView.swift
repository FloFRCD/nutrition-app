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
    
    // États pour le défilement automatique
    @State private var scrollPosition: SwiftUI.ScrollPosition = .init()
    @State private var currentScrollOffset: CGFloat = 0
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    @State private var initialAnimation: Bool = false
    @State private var isUserInteracting: Bool = false
    @State private var scrollPhase: ScrollPhase = .idle
    @State private var userSelectedStatIndex: Int? = nil
    @State private var upcomingMeals: [PlannedMeal] = []
    
    var body: some View {
        ZStack {
            // Fond principal
            AppTheme.background.ignoresSafeArea()
            
            NavigationView {
                ZStack {
                    // Contenu principal
                    ScrollView {
                        VStack(spacing: 15) {
                            // Ne pas modifier DailyProgressView, mais adapter son environnement
                            DailyProgressView(
                                userProfile: localDataManager.userProfile,
                                isExpanded: $isNutritionExpanded,
                                scrollPosition: $scrollPosition,
                                initialAnimation: initialAnimation,
                                isUserInteracting: $isUserInteracting,
                                userSelectedStatIndex: $userSelectedStatIndex,
                                currentScrollOffset: $currentScrollOffset
                            )
                            .colorScheme(.dark)
                            
                            // Next Meal Section
                            NextMealView()
                                .environmentObject(localDataManager)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cardBorderRadius)
                        }
                        .padding(.horizontal)
                    }
                    .blur(radius: isNutritionExpanded ? 3 : 0)
                    .zIndex(0)
                }
                .navigationTitle("Bonjour \(localDataManager.userProfile?.name.components(separatedBy: " ").first ?? "")")
                .foregroundColor(AppTheme.primaryText)
            }
            .accentColor(AppTheme.accent)
            .zIndex(0)
            
            // Overlay sombre et vue expandée
            if isNutritionExpanded, let profile = localDataManager.userProfile {
                ZStack {
                    Color.black.opacity(0.7)
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
                    .background(AppTheme.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.3), radius: 10)
                    .padding(.horizontal)
                    .foregroundColor(AppTheme.primaryText)
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onReceive(timer) { _ in
            currentScrollOffset += 0.15
            scrollPosition.scrollTo(x: currentScrollOffset)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.35))
            
            withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                initialAnimation = true
            }
        }
        .preferredColorScheme(.dark)
    }
}


