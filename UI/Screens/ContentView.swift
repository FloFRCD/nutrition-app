//
//  ContentView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var localDataManager = LocalDataManager.shared
    
    var body: some View {
        Group {
            if localDataManager.userProfile == nil {
                InitialSetupView()
            } else {
                MainTabView()
            }
        }
    }
}
