//
//  InitialSetupViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

// InitialSetupViewModel.swift
class InitialSetupViewModel: ObservableObject {
    // Vos propriétés existantes
    @Published var name = ""
    @Published var birthDate = Date()
    @Published var gender: Gender = .male
    @Published var height: Double = 170
    @Published var currentWeight: Double = 70
    @Published var dietaryRestriction: [DietaryRestriction] = []
    @Published var bodyFatPercentage: Double? = nil
    @Published var fitnessGoal: FitnessGoal = .maintainWeight
    
    // Remplacer activityLevel par les détails d'activité
    @Published var exerciseDaysPerWeek: Int = 3
    @Published var exerciseDuration: Int = 45
    @Published var exerciseIntensity: ExerciseIntensity = .moderate
    @Published var jobActivity: JobActivityLevel = .seated
    @Published var dailyActivity: DailyActivityLevel = .moderate
    
    var isPersonalInfoValid: Bool {
        !name.isEmpty
    }

    var isMeasurementsValid: Bool {
        let weightValid = currentWeight > 30 && currentWeight < 250
        let heightValid = height > 100 && height < 250
        let bodyFatValid = bodyFatPercentage == nil ||
            (bodyFatPercentage! >= 0 && bodyFatPercentage! <= 100)
        return weightValid && heightValid && bodyFatValid
    }
    
    
    
    // Propriété calculée pour obtenir le facteur d'activité
    var calculatedActivityLevel: ActivityLevel {
        let activityDetails = ActivityDetails(
            exerciseDaysPerWeek: exerciseDaysPerWeek,
            exerciseDuration: exerciseDuration,
            exerciseIntensity: exerciseIntensity,
            jobActivity: jobActivity,
            dailyActivity: dailyActivity
        )
        
        let factor = calculateActivityFactor(details: activityDetails)
        
        // Convertir le facteur calculé en ActivityLevel
        switch factor {
        case 1.0...1.25: return .sedentary
        case 1.25...1.4: return .lightlyActive
        case 1.4...1.6: return .moderatelyActive
        case 1.6...1.8: return .veryActive
        default: return .extraActive
        }
    }
    
    // Le reste de vos méthodes existantes
    
    func completeSetup() async {
        let userProfile = UserProfile(
            id: UUID(),
            name: self.name,
            age: Calendar.current.dateComponents([.year], from: self.birthDate, to: Date()).year ?? 0,
            gender: self.gender,
            height: self.height,
            weight: self.currentWeight,
            bodyFatPercentage: self.bodyFatPercentage,
            fitnessGoal: self.fitnessGoal,
            activityLevel: self.calculatedActivityLevel,
            dietaryRestrictions: self.dietaryRestriction.map { $0.displayName },
            activityDetails: ActivityDetails(
                exerciseDaysPerWeek: self.exerciseDaysPerWeek,
                exerciseDuration: self.exerciseDuration,
                exerciseIntensity: self.exerciseIntensity,
                jobActivity: self.jobActivity,
                dailyActivity: self.dailyActivity
            )
        )
        print("Profil à sauvegarder:")
        print("Nom: \(name)")
        print("Taille: \(height)")
        print("Poids: \(currentWeight)")
        print("Age: \(birthDate)")
        print("- Niveau d'activité calculé: \(calculatedActivityLevel)")
        print("- Détails d'activité:")
        print("  • Jours d'exercice: \(exerciseDaysPerWeek)")
        print("  • Durée: \(exerciseDuration) minutes")
        print("  • Intensité: \(exerciseIntensity)")
        print("  • Activité professionnelle: \(jobActivity)")
        print("  • Activité quotidienne: \(dailyActivity)")
        
        do {
            try await LocalDataManager.shared.save(userProfile, forKey: "userProfile")
            
            // Utiliser DispatchQueue.main pour mettre à jour les propriétés publiées
            DispatchQueue.main.async {
                LocalDataManager.shared.userProfile = userProfile
            }
            
            print("✅ Profil sauvegardé avec succès")
        } catch {
            print("❌ Erreur lors de la sauvegarde: \(error)")
        }
    }
    
    func canProceedFromCurrentPage(_ page: Int) -> Bool {
            switch page {
            case 0: return isPersonalInfoValid
            case 1: return isMeasurementsValid
            case 2, 3: return true
            default: return false
            }
        }
}
