//
//  ContentView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @StateObject private var journalViewModel = JournalViewModel()
    
    var body: some View {
        Group {
            if localDataManager.userProfile == nil {
                InitialSetupView()
                    .environmentObject(localDataManager)
            } else {
                MainTabView()
                    .environmentObject(journalViewModel)
                    .environmentObject(localDataManager)
            }
        }
        .task {
//            UserDefaults.standard.removeObject(forKey: "userProfile")
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

