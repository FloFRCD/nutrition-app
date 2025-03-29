//
//  ProfileEditView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/02/2025.
//

import Foundation
import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var localDataManager: LocalDataManager
    
    @State private var weight: Double
    @State private var height: Double
    @State private var bodyFatPercentage: Double? = nil
    @State private var selectedGoal: FitnessGoal
    @State private var selectedActivityLevel: ActivityLevel // Ajout du niveau d'activité
    @State private var showAlert = false
    @State private var showBodyFat: Bool
    
    init(userProfile: UserProfile) {
        _weight = State(initialValue: userProfile.weight)
        _height = State(initialValue: userProfile.height)
        _bodyFatPercentage = State(initialValue: userProfile.bodyFatPercentage)
        _selectedGoal = State(initialValue: userProfile.fitnessGoal)
        _selectedActivityLevel = State(initialValue: userProfile.activityLevel) // Initialisation
        _showBodyFat = State(initialValue: userProfile.bodyFatPercentage != nil)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Section des mensurations
                    measurementsSection
                    
                    // Section des objectifs
                    objectivesSection
                    
                    // Section du niveau d'activité (nouveau)
                    activityLevelSection
                    
                    
                }
                .padding()
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveProfile()
                    }
                }
            }
            .alert("Erreur", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Veuillez vérifier les valeurs saisies")
            }
        }
    }
    
    // Nouvelle section pour le niveau d'activité
    private var activityLevelSection: some View {
        VStack(spacing: 24) {
            Text("Niveau d'activité")
                .font(.title2)
                .bold()
            
            VStack(spacing: 16) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Button(action: {
                        selectedActivityLevel = level
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                    .font(.headline)
                            }
                            Spacer()
                            if selectedActivityLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedActivityLevel == level ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private func saveProfile() {
        print("=== SAUVEGARDE DU PROFIL ===")
            print("Nouvelles valeurs:")
            print("Poids:", weight)
            print("Masse graisseuse:", bodyFatPercentage ?? "non renseignée")
        
        guard weight > 0 && height > 0 &&
                (bodyFatPercentage ?? 0) >= 0 && (bodyFatPercentage ?? 0) <= 100 else {
            showAlert = true
            return
        }
        
        Task {
            if var profile = localDataManager.userProfile {
                profile.weight = weight
                profile.height = height
                profile.bodyFatPercentage = showBodyFat ? bodyFatPercentage : nil
                profile.fitnessGoal = selectedGoal
                profile.activityLevel = selectedActivityLevel // Mise à jour du niveau d'activité
                
                try? await localDataManager.save(profile, forKey: "userProfile")
                print("Profil sauvegardé avec succès")
                await MainActor.run {
                    localDataManager.userProfile = profile
                    dismiss()
                }
            }
        }
    }
    
    private var objectivesSection: some View {
        VStack(spacing: 24) {
            Text("Votre objectif")
                .font(.title2)
                .bold()
            
            VStack(spacing: 16) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    Button(action: {
                        selectedGoal = goal
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.rawValue)
                                    .font(.headline)
                            }
                            Spacer()
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedGoal == goal ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private var measurementsSection: some View {
            VStack(spacing: 24) {
                Text("Vos mensurations")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 16) {
                    // Champs de base
                    weightHeightFields
                    
                    // Toggle et champs de masse graisseuse
                    bodyFatFields
                    
                    // Informations calculées
                    if bodyFatPercentage != nil {
                        calculatedInfos
                    }
                }
                .padding()
            }
        }
        
    private var weightHeightFields: some View {
           VStack(spacing: 16) {
               HStack {
                   Text("Poids actuel")
                   Spacer()
                   TextField("kg", value: $weight, format: .number)
                       .textFieldStyle(.roundedBorder)
                       .keyboardType(.decimalPad)
                       .frame(width: 100)
                   Text("kg")
               }
               
               HStack {
                   Text("Taille")
                   Spacer()
                   TextField("cm", value: $height, format: .number)
                       .textFieldStyle(.roundedBorder)
                       .keyboardType(.decimalPad)
                       .frame(width: 100)
                   Text("cm")
               }
           }
       }
        
        private var bodyFatFields: some View {
            VStack(spacing: 16) {
                Toggle("Je connais mon % de masse graisseuse", isOn: Binding(
                    get: { bodyFatPercentage != nil },
                    set: { newValue in
                        if !newValue {
                            bodyFatPercentage = nil
                            showBodyFat = false
                        } else {
                            bodyFatPercentage = 20
                            showBodyFat = true
                        }
                    }
                ))
                
                if bodyFatPercentage != nil {
                    HStack {
                        Text("% de masse graisseuse")
                        Spacer()
                        TextField("%", value: Binding(
                            get: { bodyFatPercentage ?? 20 },
                            set: { bodyFatPercentage = $0 }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                        Text("%")
                    }
                }
            }
        }
        
        private var calculatedInfos: some View {
            VStack(alignment: .leading, spacing: 8) {
                let heightInMeters = height / 100
                let bmi = weight / (heightInMeters * heightInMeters)
                
                Text("IMC: \(bmi, specifier: "%.1f")")
                    .font(.subheadline)
                
                if let bodyFat = bodyFatPercentage {
                    let leanMass = weight * (1 - bodyFat / 100)
                    Text("Masse maigre estimée: \(leanMass, specifier: "%.1f") kg")
                        .font(.subheadline)
                }
            }
            .padding(.top)
        }
    

}
