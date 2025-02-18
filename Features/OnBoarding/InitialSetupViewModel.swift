//
//  InitialSetupViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

class InitialSetupViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var gender: Gender = .male
    @Published var birthDate: Date = Date()
    @Published var height: Double = 170
    @Published var weight: Double = 70
    @Published var isValid: Bool = false
    
    func completeSetup() {
        // Créer le profil utilisateur
        let profile = UserProfile(
            name: name,
            age: calculateAge(from: birthDate),
            gender: gender,
            height: height,
            currentWeight: weight,
            targetWeight: nil,
            activityLevel: ActivityLevel.moderatelyActive,
            dietaryPreferences: []
        )
        
        // Sauvegarder le profil
    }
    
    private func calculateAge(from date: Date) -> Int {
        Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
    }
}
