//
//  AppTheme.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 14/03/2025.
//

import Foundation
import SwiftUI

// MARK: - Theme Colors
struct AppTheme {
    // Couleurs primaires
    static let background = Color.black
    static let cardBackground = Color(hex: "121212")
    static let secondaryBackground = Color(hex: "1E1E1E")
    
    // Nouvelles couleurs basées sur le logo
    static let primaryPurple = Color(hex: "9933E6") // Violet du logo
    static let primaryBlue = Color(hex: "3366E6")   // Bleu du logo
    static let lightPink = Color(hex: "E666CC")     // Rose du logo
    
    // Couleurs d'accent mises à jour
    static let accent = primaryPurple               // Remplace le vert par le violet du logo
    static let secondaryAccent = primaryBlue        // Remplace l'ancien violet par le bleu du logo
    
    // Couleurs de texte
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "BBBBBB")
    static let tertiaryText = Color(hex: "777777")
    
    // Styles de carte
    static let cardBorderRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    
    // Gradient pour les boutons
    static var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryPurple, primaryBlue]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Extension utilitaire pour les codes couleur hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
