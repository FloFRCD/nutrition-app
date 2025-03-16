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
    static let accent = Color(hex: "36D45B") // Vert comme sur Finary
    static let secondaryAccent = Color(hex: "624CF6") // Violet comme sur Finary
    
    // Couleurs de texte
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "BBBBBB")
    static let tertiaryText = Color(hex: "777777")
    
    // Styles de carte
    static let cardBorderRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
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
