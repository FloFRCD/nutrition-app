//
//  ActivityDetails.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 08/03/2025.
//

import Foundation


// Structure pour stocker les informations détaillées d'activité
struct ActivityDetails: Codable {
    let exerciseDaysPerWeek: Int
    let exerciseDuration: Int
    let exerciseIntensity: ExerciseIntensity
    let jobActivity: JobActivityLevel
    let dailyActivity: DailyActivityLevel
}

// Calculer le facteur d'activité basé sur les détails
func calculateActivityFactor(details: ActivityDetails) -> Double {
    // Base: sédentaire
    var factor = 1.2
    
    // Ajout pour l'exercice structuré
    let weeklyExerciseMinutes = details.exerciseDaysPerWeek * details.exerciseDuration
    let exerciseAddition: Double
    
    switch (weeklyExerciseMinutes, details.exerciseIntensity) {
    case (0, _):
        exerciseAddition = 0.0
    case (1...90, .light):
        exerciseAddition = 0.05
    case (1...90, .moderate):
        exerciseAddition = 0.1
    case (1...90, .intense):
        exerciseAddition = 0.15
    case (91...180, .light):
        exerciseAddition = 0.1
    case (91...180, .moderate):
        exerciseAddition = 0.15
    case (91...180, .intense):
        exerciseAddition = 0.2
    case (181...300, .light):
        exerciseAddition = 0.15
    case (181...300, .moderate):
        exerciseAddition = 0.2
    case (181...300, .intense):
        exerciseAddition = 0.25
    case (_, .light):
        exerciseAddition = 0.2
    case (_, .moderate):
        exerciseAddition = 0.25
    case (_, .intense):
        exerciseAddition = 0.3
    }
    
    // Ajout pour l'activité professionnelle
    let jobAddition: Double
    switch details.jobActivity {
    case .seated:
        jobAddition = 0.0
    case .standing:
        jobAddition = 0.05
    case .physical:
        jobAddition = 0.1
    case .heavyPhysical:
        jobAddition = 0.15
    }
    
    // Ajout pour l'activité quotidienne
    let dailyAddition: Double
    switch details.dailyActivity {
    case .minimal:
        dailyAddition = 0.0
    case .moderate:
        dailyAddition = 0.05
    case .active:
        dailyAddition = 0.1
    }
    
    return factor + exerciseAddition + jobAddition + dailyAddition
}

enum ExerciseIntensity: String, Codable {
    case light
    case moderate
    case intense
}

enum JobActivityLevel: String, Codable {
    case seated
    case standing
    case physical
    case heavyPhysical
}

enum DailyActivityLevel: String, Codable {
    case minimal
    case moderate
    case active
}
