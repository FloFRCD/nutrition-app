//
//  MainTabView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var localDataManager: LocalDataManager
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var isTabBarVisible = true
    
    var body: some View {
        ZStack {
            // Fond blanc avec effets subtils
            AppBackgroundLight()
            
            // Contenu basé sur l'onglet sélectionné
            VStack {
                ZStack {
                    // Affichage conditionnel de la vue en fonction de l'onglet sélectionné
                    if selectedTab == 0 {
                        if #available(iOS 18.0, *) {
                            HomeView()
                        } else {
                            Text("Cette fonctionnalité nécessite iOS 18")
                                .foregroundColor(.black)
                        }
                    } else if selectedTab == 1 {
                        JournalView()
                    } else if selectedTab == 2 {
                        PlanningView()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                Spacer(minLength: 0)
            }
            
            // TabBar personnalisée fixée en bas
            VStack {
                            Spacer()
                            if isTabBarVisible {  // Condition ajoutée ici
                                CustomTabBar(selectedTab: $selectedTab, isTabBarVisible: $isTabBarVisible)
                            }
                        }
                        .ignoresSafeArea(.keyboard)
                    }
                    .environmentObject(localDataManager)
                    .environmentObject(journalViewModel)
                    .preferredColorScheme(.light)
                    .onReceive(NotificationCenter.default.publisher(for: .hideTabBar)) { _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTabBarVisible = false
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .showTabBar)) { _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTabBarVisible = true
                        }
                    }
                }
            }
