//
//  ContentView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @StateObject private var journalViewModel = JournalViewModel()
    
    var body: some View {
        Group {
            if localDataManager.userProfile == nil {
                InitialSetupView()
                    .environmentObject(localDataManager)
                    .environmentObject(storeKitManager) // 👈 ajouter ceci
            } else {
                MainTabView()
                    .environmentObject(journalViewModel)
                    .environmentObject(localDataManager)
                    .environmentObject(storeKitManager) // 👈 et ici aussi
            }
        }
        .task {
            await localDataManager.loadInitialData()
        }
    }
}


struct MainPagesView: View {
    @State private var selectedTab = 0
    @State private var isTabBarVisible = true
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @StateObject private var journalViewModel = JournalViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .environmentObject(journalViewModel)
                .environmentObject(localDataManager)

            JournalView()
                .tag(1)

            PlanningView(isTabBarVisible: $isTabBarVisible)
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // swipe horizontal
        .ignoresSafeArea()
    }
}

