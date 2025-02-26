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
                    profileContent(profile: profile)
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
    
    // Extraction du contenu dans une fonction pour réduire la complexité
    private func profileContent(profile: UserProfile) -> some View {
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
            profileInfoContent(profile: profile)
            
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
    
    // Extraction des sections d'informations
    private func profileInfoContent(profile: UserProfile) -> some View {
        VStack(spacing: 20) {
            // Informations personnelles
            personalInfoSection(profile: profile)
            
            // Mensurations
            measurementsSection(profile: profile)
            
            // Mode de vie
            lifestyleSection(profile: profile)
            
            // Besoins nutritionnels
            nutritionalNeedsSection(profile: profile)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    // Section d'informations personnelles
    private func personalInfoSection(profile: UserProfile) -> some View {
        ProfileSection(title: "Informations personnelles") {
            StatRow(title: "Nom", value: profile.name)
            StatRow(title: "Âge", value: "\(profile.age) ans")
            StatRow(title: "Genre", value: profile.gender.rawValue)
        }
    }
    
    // Section des mensurations
    private func measurementsSection(profile: UserProfile) -> some View {
        let heightInMeters = profile.height / 100
        let bmi = profile.weight / (heightInMeters * heightInMeters)
        
        return ProfileSection(title: "Mensurations") {
            StatRow(title: "Taille", value: "\(Int(profile.height)) cm")
            StatRow(title: "Poids actuel", value: "\(Int(profile.weight)) kg")
            
            // Gestion différente selon si bodyFatPercentage est disponible
            if let bodyFatPercentage = profile.bodyFatPercentage {
                StatRow(title: "Masse graisseuse", value: "\(Int(bodyFatPercentage))%")
                let leanMass = profile.weight * (1 - bodyFatPercentage / 100)
                StatRow(title: "Masse maigre", value: "\(Int(leanMass)) kg")
            } else {
                StatRow(title: "Masse graisseuse", value: "Non renseigné")
                StatRow(title: "Masse maigre", value: "Non renseigné")
            }
            
            StatRow(title: "IMC", value: String(format: "%.1f", bmi))
        }
    }
    
    // Section mode de vie
    private func lifestyleSection(profile: UserProfile) -> some View {
        ProfileSection(title: "Mode de vie") {
            StatRow(title: "Objectif", value: profile.fitnessGoal.rawValue)
            StatRow(title: "Niveau d'activité", value: profile.activityLevel.rawValue)
            if !profile.dietaryRestrictions.isEmpty {
                StatRow(title: "Préférences alimentaires",
                       value: profile.dietaryRestrictions
                        .joined(separator: ", "))
            }
        }
    }
    
    // Section besoins nutritionnels
    private func nutritionalNeedsSection(profile: UserProfile) -> some View {
        let needs = NutritionCalculator.shared.calculateNeeds(for: profile)
        
        return ProfileSection(title: "Besoins nutritionnels") {
            StatRow(title: "Calories de maintenance", value: "\(Int(needs.maintenanceCalories)) kcal")
            StatRow(title: "Calories recommandées", value: "\(Int(needs.targetCalories)) kcal")
            StatRow(title: "Protéines", value: "\(Int(needs.proteins))g")
            StatRow(title: "Glucides", value: "\(Int(needs.carbs))g")
            StatRow(title: "Lipides", value: "\(Int(needs.fats))g")
        }
    }
}
