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
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    if let profile = localDataManager.userProfile {
                        profileContent(profile: profile)
                    }
                }
                .navigationTitle("Profil")
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = localDataManager.userProfile {
                    ProfileEditView(userProfile: profile)
                        .preferredColorScheme(.dark)
                        .accentColor(AppTheme.accent)
                }
            }
            .foregroundColor(AppTheme.primaryText)
        }
        .accentColor(AppTheme.accent)
        .preferredColorScheme(.dark)
    }
    
    // Extraction du contenu dans une fonction pour réduire la complexité
    private func profileContent(profile: UserProfile) -> some View {
        VStack(spacing: 20) {
            // Photo de profil
            Circle()
                .fill(AppTheme.secondaryBackground)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.secondaryText)
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
                    .background(AppTheme.buttonGradient)
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
        .background(AppTheme.cardBackground)
        .cornerRadius(15)
    }
    
    // Section d'informations personnelles
    private func personalInfoSection(profile: UserProfile) -> some View {
        ProfileSection(title: "Informations personnelles") {
            StatRow(title: "Nom", value: profile.name)
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Âge", value: "\(profile.age) ans")
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Genre", value: profile.gender.rawValue)
                .foregroundColor(AppTheme.primaryText)
        }
        .foregroundColor(AppTheme.primaryText)
    }
    
    // Section des mensurations
    private func measurementsSection(profile: UserProfile) -> some View {
        let heightInMeters = profile.height / 100
        let bmi = profile.weight / (heightInMeters * heightInMeters)
        
        return ProfileSection(title: "Mensurations") {
            StatRow(title: "Taille", value: "\(Int(profile.height)) cm")
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Poids actuel", value: "\(Int(profile.weight)) kg")
                .foregroundColor(AppTheme.primaryText)
            
            // Gestion différente selon si bodyFatPercentage est disponible
            if let bodyFatPercentage = profile.bodyFatPercentage {
                StatRow(title: "Masse graisseuse", value: "\(Int(bodyFatPercentage))%")
                    .foregroundColor(AppTheme.primaryText)
                let leanMass = profile.weight * (1 - bodyFatPercentage / 100)
                StatRow(title: "Masse maigre", value: "\(Int(leanMass)) kg")
                    .foregroundColor(AppTheme.primaryText)
            } else {
                StatRow(title: "Masse graisseuse", value: "Non renseigné")
                    .foregroundColor(AppTheme.primaryText)
                StatRow(title: "Masse maigre", value: "Non renseigné")
                    .foregroundColor(AppTheme.primaryText)
            }
            
            StatRow(title: "IMC", value: String(format: "%.1f", bmi))
                .foregroundColor(AppTheme.primaryText)
        }
        .foregroundColor(AppTheme.primaryText)
    }
    
    // Section mode de vie
    private func lifestyleSection(profile: UserProfile) -> some View {
        ProfileSection(title: "Mode de vie") {
            StatRow(title: "Objectif", value: profile.fitnessGoal.rawValue)
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Niveau d'activité", value: profile.activityLevel.rawValue)
                .foregroundColor(AppTheme.primaryText)
            if !profile.dietaryRestrictions.isEmpty {
                StatRow(title: "Préférences alimentaires",
                       value: profile.dietaryRestrictions
                        .joined(separator: ", "))
                .foregroundColor(AppTheme.primaryText)
            }
        }
        .foregroundColor(AppTheme.primaryText)
    }
    
    // Section besoins nutritionnels
    private func nutritionalNeedsSection(profile: UserProfile) -> some View {
        let needs = NutritionCalculator.shared.calculateNeeds(for: profile)
        
        return ProfileSection(title: "Besoins nutritionnels") {
            StatRow(title: "Calories de maintenance", value: "\(Int(needs.maintenanceCalories)) kcal")
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Calories recommandées", value: "\(Int(needs.targetCalories)) kcal")
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Protéines", value: "\(Int(needs.proteins))g")
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Glucides", value: "\(Int(needs.carbs))g")
                .foregroundColor(AppTheme.primaryText)
            StatRow(title: "Lipides", value: "\(Int(needs.fats))g")
                .foregroundColor(AppTheme.primaryText)
        }
        .foregroundColor(AppTheme.primaryText)
    }
}
