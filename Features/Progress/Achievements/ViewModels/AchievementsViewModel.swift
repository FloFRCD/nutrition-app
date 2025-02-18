//
//  AchievementsViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = [
        Achievement(
            name: "Premier pas",
            description: "Enregistrer votre premier repas",
            icon: "fork.knife"
        ),
        Achievement(
            name: "Photographe culinaire",
            description: "Prendre 5 photos de repas",
            icon: "camera"
        ),
        Achievement(
            name: "En bonne voie",
            description: "Suivre vos repas pendant 7 jours consécutifs",
            icon: "flame"
        ),
        Achievement(
            name: "Expert nutrition",
            description: "Atteindre vos objectifs caloriques pendant 5 jours",
            icon: "star.fill"
        )
    ]
    
    func loadAchievements() {
        // À implémenter avec LocalDataManager
    }
    
    func unlockAchievement(_ id: UUID) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()
            // Sauvegarder dans LocalDataManager
        }
    }
}
