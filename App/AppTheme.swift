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
    
    // Couleurs principales basées sur l'image
    static let primaryPurple = Color(hex: "9933FF") // Violet plus vif du logo/UI
    static let primaryBlue = Color(hex: "3366FF")   // Bleu plus vif
    static let lightPink = Color(hex: "E666CC")     // Rose pour les accents
    static let vibrantGreen = Color(hex: "44CC44")  // Vert pour les boutons d'action
    
    // Couleurs d'accent mises à jour
    static let accent = vibrantGreen
    static let secondaryAccent = primaryBlue
    static let actionAccent = vibrantGreen
    
    // Couleurs de texte
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "BBBBBB")
    static let tertiaryText = Color(hex: "777777")
    
    // Styles de carte
    static let cardBorderRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    
    // Propriétés pour la TabBar
    static let tabBarBackground = Color.black.opacity(0.7)
    static let tabBarActiveBlur = Color.white.opacity(0.15)
    static let tabBarUnselectedItemColor = Color.gray
    
    // Couleurs pour les boutons
    static let primaryButtonBackground = primaryPurple
    static let secondaryButtonBackground = Color(hex: "333333")
    static let actionButtonBackground = vibrantGreen
    
    // Couleurs pour les blobs d'arrière-plan
    static let backgroundBlob1 = primaryPurple.opacity(0.30)
    static let backgroundBlob2 = primaryBlue.opacity(0.30)
    static let backgroundBlob3 = lightPink.opacity(0.15)
    
    // Gradient pour les boutons
    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [vibrantGreen, secondaryAccent]), // vert → bleu
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // Gradient pour le bouton d'action (comme le bouton Scanner vert)
    static var tabBarGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.white, vibrantGreen.opacity(0.1)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var actionButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [vibrantGreen, vibrantGreen.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Gradient pour l'arrière-plan de la tabBar sélectionnée
    static var selectedTabGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryBlue.opacity(0.7), vibrantGreen.opacity(0.5)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
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


