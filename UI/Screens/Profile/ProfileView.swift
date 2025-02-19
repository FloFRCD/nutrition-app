//
//  ProfileView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Photo de profil
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                    
                    // Stats
                    VStack(spacing: 20) {
                        StatRow(title: "Poids actuel", value: "-- kg")
                        StatRow(title: "Objectif", value: "-- kg")
                        StatRow(title: "Calories journalières", value: "-- kcal")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("Profil")
        }
    }
}
#Preview {
    ProfileView()
}
