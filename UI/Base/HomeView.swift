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
    @State private var isTabBarVisible = true
    
    //bouton profil annimé
    @State private var playAnimation = false
    @State private var showProfile = false

    
    // États pour le défilement automatique
    @State private var scrollPosition: SwiftUI.ScrollPosition = .init()
    @State private var currentScrollOffset: CGFloat = 0
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    @State private var initialAnimation: Bool = false
    @State private var isUserInteracting: Bool = false
    @State private var scrollPhase: ScrollPhase = .idle
    @State private var userSelectedStatIndex: Int? = nil
    @State private var upcomingMeals: [PlannedMeal] = []
    @State private var centeredCardID: String? = nil
    
    
    // Déterminer le type actif basé sur l'index sélectionné
    private var activeStatType: StatType? {
        guard let index = userSelectedStatIndex else { return nil }
        
        let types: [StatType] = [.calories, .proteins, .carbohydrates, .fats, .fiber, .water]
        return index < types.count ? types[index] : nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fond dynamique qui change avec la carte sélectionnée
                AnimatedBackground()
                
                VStack(spacing: 0) {
                    // En-tête avec logo et bouton profil (reste inchangé)
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
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Button {
                            
                            playAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                isTabBarVisible = false
                                showProfile = true
                            }
                        } label: {
                            VStack(spacing: 4) {
                                LottieProfileIcon(play: $playAnimation)
                                    .frame(width: 40, height: 40)

                                Text("Profil")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .opacity(0.7)
                            }
                        }


                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Carousel de statistiques (transmet l'index sélectionné)
                    DailyProgressView(
                        userProfile: localDataManager.userProfile,
                        isExpanded: $isNutritionExpanded,
                        scrollPosition: $scrollPosition,
                        initialAnimation: initialAnimation,
                        isUserInteracting: $isUserInteracting,
                        userSelectedStatIndex: $userSelectedStatIndex,
                        currentScrollOffset: $currentScrollOffset
                    )
                    .scrollTargetLayout()
                    .scrollPosition(id: $centeredCardID)
                    .onChange(of: centeredCardID) { oldValue, newValue in
                        if let newID = newValue {
                            // Convertir l'ID en index
                            userSelectedStatIndex = convertIDToIndex(newID)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // Le reste du contenu en cartes blanches
                    ScrollView {
                        VStack(spacing: 15) {
                            // Carte de repas en blanc
                            NextMealView()
                                .environmentObject(localDataManager)
                                .background(Color.white)
                                .cornerRadius(AppTheme.cardBorderRadius)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            // Espace en bas
                            Spacer().frame(height: 80)
                        }
                        .padding(.horizontal)
                    }
                }
                .blur(radius: isNutritionExpanded ? 3 : 0)
                .zIndex(0)
                
                // Overlay pour la vue expandée (reste largement inchangé)
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
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 15)
                        .padding(.horizontal)
                        .foregroundColor(.black)
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView(isTabBarVisible: $isTabBarVisible)
            }
            .navigationTitle("Accueil")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .tint(.black)
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
        .preferredColorScheme(.light)
    }
}

extension HomeView {
    private func convertIDToIndex(_ id: String) -> Int {
        // Supposons que vos IDs sont au format "stat_0", "stat_1", etc.
        if let indexString = id.split(separator: "_").last,
           let index = Int(indexString) {
            return index
        }
        return 0 // Valeur par défaut
    }
}
