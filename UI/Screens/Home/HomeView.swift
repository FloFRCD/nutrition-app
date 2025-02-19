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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Progress Section
                    DailyProgressView(userProfile: localDataManager.userProfile)
                    
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
                .padding()
            }
            .navigationTitle("Bonjour \(localDataManager.userProfile?.name.components(separatedBy: " ").first ?? "")")
        }
    }
}


