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
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    @Published var dietaryPreferences: [DietaryPreference] = []
    @Published private var bodyFatPercentage: Double = 20
    @Published var fitnessGoal: FitnessGoal = .maintenance
    
    // Propriétés calculées pour la validation
        var isPersonalInfoValid: Bool {
            !name.isEmpty
        }
    
    var isMeasurementsValid: Bool {
            let weightValid = currentWeight > 30 && currentWeight < 250
            let heightValid = height > 100 && height < 250
            let bodyFatValid = bodyFatPercentage == nil ||
        (bodyFatPercentage >= 0 && bodyFatPercentage <= 100)
            return weightValid && heightValid && bodyFatValid
        }
    
    func canProceedFromCurrentPage(_ page: Int) -> Bool {
            switch page {
            case 0: return isPersonalInfoValid
            case 1: return isMeasurementsValid
            case 2, 3: return true // Ces pages sont toujours valides
            default: return false
            }
        }
    
    func completeSetup() async {
        let userProfile = UserProfile(
            id: UUID(),
            name: name,
            age: Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0,
            gender: gender,
            height: height,
            currentWeight: currentWeight,  // Vérifier que currentWeight est bien 85kg
            bodyFatPercentage: bodyFatPercentage,  // Devrait être nil
            fitnessGoal: fitnessGoal,
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
