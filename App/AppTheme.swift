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

    // Couleurs inspirées du logo NutrIA
    static let logoYellow = Color(hex: "FFD54F")
    static let logoPurple = Color(hex: "B39DDB")
    static let logoBlue = Color(hex: "3A5BA0")
    static let logoGreen = Color(hex: "66BB6A")

    // Couleurs primaires
    static let background = Color.black
    static let cardBackground = Color(hex: "121212")
    static let secondaryBackground = Color(hex: "1E1E1E")

    // Couleurs principales basées sur le logo
    static let primaryPurple = logoPurple
    static let primaryBlue = logoBlue
    static let lightYellow = logoYellow
    static let vibrantGreen = logoBlue

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
    static let backgroundBlob3 = lightYellow.opacity(0.15)

    // Gradient pour les boutons
    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [vibrantGreen, secondaryAccent]),
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

    static let actionButtonProgressGradient = LinearGradient(
        gradient: Gradient(colors: [accent, accent.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let progressGradient = LinearGradient(
        gradient: Gradient(colors: [logoGreen, accent]),
        startPoint: .leading,
        endPoint: .trailing
    )
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

struct PremiumGradientButton: View {
    let title: String
    let subtitle: String?
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(gradient, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 4)
        }
    }
}


