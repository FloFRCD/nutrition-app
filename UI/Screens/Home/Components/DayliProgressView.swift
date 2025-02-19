//
//  DayliProgressView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct DailyProgressView: View {
    let userProfile: UserProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Aujourd'hui")
                .font(.headline)
            
            if let profile = userProfile {
                HStack {
                    ProgressCard(
                        title: "Calories",
                        current: "0",
                        target: "\(calculateDailyCalories(profile))"
                    )
                    ProgressCard(
                        title: "Protéines",
                        current: "0",
                        target: "\(calculateDailyProteins(profile))g"
                    )
                    ProgressCard(
                        title: "Eau",
                        current: "0",
                        target: "2.5L"
                    )
                }
            } else {
                Text("Chargement...")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    // Fonctions de calcul des objectifs basées sur le profil
    private func calculateDailyCalories(_ profile: UserProfile) -> Int {
        // Calcul basique du BMR (Basal Metabolic Rate) avec l'équation de Harris-Benedict
        let bmr: Double
        switch profile.gender {
        case .male:
            bmr = 88.362 + (13.397 * profile.currentWeight) + (4.799 * profile.height) - (5.677 * Double(profile.age))
        case .female:
            bmr = 447.593 + (9.247 * profile.currentWeight) + (3.098 * profile.height) - (4.330 * Double(profile.age))
        case .other:
            // Moyenne des deux formules
            bmr = (88.362 + (13.397 * profile.currentWeight) + (4.799 * profile.height) - (5.677 * Double(profile.age)) +
                   447.593 + (9.247 * profile.currentWeight) + (3.098 * profile.height) - (4.330 * Double(profile.age))) / 2
        }
        
        // Facteur d'activité
        let activityFactor: Double
        switch profile.activityLevel {
        case .sedentary: activityFactor = 1.2
        case .lightlyActive: activityFactor = 1.375
        case .moderatelyActive: activityFactor = 1.55
        case .veryActive: activityFactor = 1.725
        case .extraActive: activityFactor = 1.9
        }
        
        return Int(bmr * activityFactor)
    }
    
    private func calculateDailyProteins(_ profile: UserProfile) -> Int {
        // Calcul basique : 1.6g par kg de poids corporel pour la prise de masse
        // 2g par kg pour la perte de poids
        // 1.2g par kg pour le maintien
        let factor: Double
        if let targetWeight = profile.targetWeight {
            if targetWeight > profile.currentWeight {
                factor = 1.6 // Prise de masse
            } else if targetWeight < profile.currentWeight {
                factor = 2.0 // Perte de poids
            } else {
                factor = 1.2 // Maintien
            }
        } else {
            factor = 1.2 // Pas d'objectif défini
        }
        
        return Int(profile.currentWeight * factor)
    }
}
