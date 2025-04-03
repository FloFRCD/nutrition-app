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
            await localDataManager.loadInitialData()
        }
    }
}

