//
//  CustomButton.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI
import StoreKit
import AVFoundation

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(style.textColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(style.backgroundColor)
                .cornerRadius(12)
        }
    }
}

enum ButtonStyle {
    case primary
    case secondary
    case destructive
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .blue
        case .secondary:
            return .gray.opacity(0.2)
        case .destructive:
            return .red
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return .primary
        case .destructive:
            return .white
        }
    }
}

// Style pour le bouton principal
struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.primaryButtonBackground)
            .cornerRadius(20)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

// Style pour le bouton d'action
struct ActionButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.actionButtonBackground)
            .cornerRadius(20)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

// Style pour le bouton secondaire
struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.secondaryButtonBackground)
            .cornerRadius(20)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

// Extensions pour faciliter l'utilisation
extension View {
    func primaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonStyle())
    }
    
    func actionButtonStyle() -> some View {
        self.modifier(ActionButtonStyle())
    }
    
    func secondaryButtonStyle() -> some View {
        self.modifier(SecondaryButtonStyle())
    }
}
