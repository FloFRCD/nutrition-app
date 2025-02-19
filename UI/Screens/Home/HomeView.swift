//
//  HomeView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI


struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Progress Section
                    DailyProgressView()
                    
                    // Next Meal Section
                    NextMealView()
                    
                    // Recent Scans Section
                    RecentScansView()
                }
                .padding()
            }
            .navigationTitle("Bonjour 👋")
        }
    }
}
#Preview {
    HomeView()
}
