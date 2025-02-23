//
//  ProfileView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let profile = localDataManager.userProfile {
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
                        
                        // Informations personnelles
                        VStack(spacing: 20) {
                            ProfileSection(title: "Informations personnelles") {
                                StatRow(title: "Nom", value: profile.name)
                                StatRow(title: "Âge", value: "\(profile.age) ans")
                                StatRow(title: "Genre", value: profile.gender.rawValue)
                            }
                            
                            // Mensurations
                            ProfileSection(title: "Mensurations") {
                                let heightInMeters = profile.height / 100
                                let bmi = profile.currentWeight / (heightInMeters * heightInMeters)

                                StatRow(title: "Taille", value: "\(Int(profile.height)) cm")
                                StatRow(title: "Poids actuel", value: "\(Int(profile.currentWeight)) kg")
                                
                                // Gestion différente selon si bodyFatPercentage est disponible
                                if let bodyFatPercentage = profile.bodyFatPercentage {
                                    StatRow(title: "Masse graisseuse", value: "\(Int(bodyFatPercentage))%")
                                    let leanMass = profile.currentWeight * (1 - bodyFatPercentage / 100)
                                    StatRow(title: "Masse maigre", value: "\(Int(leanMass)) kg")
                                } else {
                                    StatRow(title: "Masse graisseuse", value: "Non renseigné")
                                    StatRow(title: "Masse maigre", value: "Non renseigné")
                                }
                                
                                StatRow(title: "IMC", value: String(format: "%.1f", bmi))
                            }
                            
                            // Mode de vie
                            ProfileSection(title: "Mode de vie") {
                                StatRow(title: "Objectif", value: profile.fitnessGoal.rawValue)
                                StatRow(title: "Niveau d'activité", value: profile.activityLevel.rawValue)
                                if !profile.dietaryPreferences.isEmpty {
                                    StatRow(title: "Préférences alimentaires",
                                           value: profile.dietaryPreferences
                                            .map { $0.rawValue }
                                            .joined(separator: ", "))
                                }
                            }
                            
                            ProfileSection(title: "Besoins nutritionnels") {
                                let needs = NutritionCalculator.shared.calculateNeeds(for: profile)
                                StatRow(title: "Calories de maintenance", value: "\(needs.maintenanceCalories) kcal")
                                StatRow(title: "Calories recommandées", value: "\(needs.targetCalories) kcal")
                                StatRow(title: "Protéines", value: "\(needs.proteins)g")
                                StatRow(title: "Glucides", value: "\(needs.carbs)g")
                                StatRow(title: "Lipides", value: "\(needs.fats)g")
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Bouton de modification
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("Modifier le profil")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showingEditProfile) {
                if let profile = localDataManager.userProfile {
                    ProfileEditView(userProfile: profile)
                }
            }
        }
    }
}
