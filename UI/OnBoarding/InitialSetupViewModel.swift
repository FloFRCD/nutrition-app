//
//  InitialSetupViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

// InitialSetupViewModel.swift
class InitialSetupViewModel: ObservableObject {
    @Published var name = ""
    @Published var birthDate = Date()
    @Published var gender: Gender = .male
    @Published var height: Double = 170
    @Published var currentWeight: Double = 70
    @Published var targetWeight: Double?
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    @Published var dietaryPreferences: [DietaryPreference] = []
    
    func canProceedFromCurrentPage(_ page: Int) -> Bool {
        switch page {
        case 0: // Page des informations personnelles
            return !name.isEmpty
        case 1: // Page des mensurations
            return currentWeight > 30 && currentWeight < 250 &&
                   height > 100 && height < 250
        case 2: // Page du mode de vie
            return true // Toujours valide car choix par défaut
        case 3: // Page des objectifs
            return targetWeight == nil || (targetWeight! > 30 && targetWeight! < 250)
        default:
            return false
        }
    }
    
    func completeSetup() async {
        let userProfile = UserProfile(
            name: name,
            age: Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0,
            gender: gender,
            height: height,
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            activityLevel: activityLevel,
            dietaryPreferences: dietaryPreferences
        )
        
        do {
            try await LocalDataManager.shared.save(userProfile, forKey: "userProfile")
            LocalDataManager.shared.userProfile = userProfile
        } catch {
            print("Erreur lors de la sauvegarde du profil: \(error)")
        }
    }
}
