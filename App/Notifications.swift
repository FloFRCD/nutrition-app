//
//  Notifications.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 29/03/2025.
//


import Foundation

// Extensions des notifications pour la communication entre les vues
extension Notification.Name {
    /// Notification pour fermer toutes les sheets modales et revenir à la vue principale
    static let dismissAllSheets = Notification.Name("dismissAllSheets")
    
    /// Notification pour mettre à jour le journal alimentaire
    static let refreshFoodJournal = Notification.Name("refreshFoodJournal")
    
    // Vous pourrez ajouter d'autres notifications ici au besoin
}
