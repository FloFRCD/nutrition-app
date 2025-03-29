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
    @State private var showingScanView = false
    
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
        NavigationView {
            ZStack {
                // Fond principal
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        VStack(alignment: .center, spacing: 4) {
                            Image("Icon-scan")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            Text("NutrIA")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.primaryText)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: ProfileView()) {
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: "atom")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                
                                Text("Profil")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Carousel fixe (toujours visible)
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
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // Contenu défilant
                    ScrollView {
                        VStack(spacing: 15) {
                            // Section Scanner compacte comme carte
                            ScannerCardView(onScanTap: {
                                showingScanView = true
                            })
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.cardBorderRadius)
                            
                            // Section Repas
                            NextMealView()
                                .environmentObject(localDataManager)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cardBorderRadius)
                            
                            // Espace en bas
                            Spacer().frame(height: 30)
                        }
                        .padding(.horizontal)
                    }
                }
                .blur(radius: isNutritionExpanded ? 3 : 0)
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
            .navigationBarHidden(true)
            .onReceive(timer) { _ in
                if !isUserInteracting {
                    currentScrollOffset += 0.15
                    scrollPosition.scrollTo(x: currentScrollOffset)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(0.35))
                
                withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                    initialAnimation = true
                }
            }
        }
        .sheet(isPresented: $showingScanView) {
            NavigationView {
                ScanView()
                    .navigationTitle("Scanner un aliment")
                    .navigationBarItems(trailing: Button("Fermer") {
                        showingScanView = false
                    })
            }
        }
        .preferredColorScheme(.dark)
    }
}

