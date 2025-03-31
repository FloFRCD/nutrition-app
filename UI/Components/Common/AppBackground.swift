//
//  AppBackground.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 30/03/2025.
//

import Foundation
import SwiftUI
import CoreMotion


struct AppBackgroundDark: View {
    var body: some View {
        ZStack {
            // Fond principal noir
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Blob effet 1 - violet avec flou
            Circle()
                .fill(AppTheme.primaryPurple.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -100, y: -180)
                .blendMode(.lighten)
            
            // Blob effet 2 - bleu avec flou
            Circle()
                .fill(AppTheme.primaryBlue.opacity(0.15))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: 120, y: 200)
                .blendMode(.lighten)
            
            // Effet supplémentaire pour plus de profondeur
            Ellipse()
                .fill(AppTheme.lightPink.opacity(0.08))
                .frame(width: 250, height: 200)
                .blur(radius: 60)
                .offset(x: 50, y: -50)
                .blendMode(.overlay)
        }
    }
}

struct AppBackgroundLight: View {
    var body: some View {
        ZStack {
            // Fond principal blanc
            Color.white.edgesIgnoringSafeArea(.all)
            
            // Blob effet 1 - violet clair avec flou
            Circle()
                .fill(AppTheme.primaryPurple.opacity(0.05))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -100, y: -180)
            
            // Blob effet 2 - bleu clair avec flou
            Circle()
                .fill(AppTheme.primaryBlue.opacity(0.05))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: 120, y: 200)
            
            // Effet supplémentaire pour plus de profondeur
            Ellipse()
                .fill(AppTheme.lightPink.opacity(0.03))
                .frame(width: 250, height: 200)
                .blur(radius: 60)
                .offset(x: 50, y: -50)
        }
    }
}

struct DynamicBackground: View {
    var activeType: StatType?
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Fond blanc de base
            Color.white.edgesIgnoringSafeArea(.all)
            
            if let type = activeType {
                // Blob principal de la couleur du type actif
                Circle()
                    .fill(type.textColor.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 70)
                    .offset(x: -100, y: -180)
                    .animation(.easeInOut(duration: 1.5), value: type)
                
                // Blob secondaire avec une nuance différente
                Circle()
                    .fill(type.textColor.opacity(0.08))
                    .frame(width: 350, height: 350)
                    .blur(radius: 80)
                    .offset(x: 120, y: 200)
                    .animation(.easeInOut(duration: 1.5), value: type)
                
                // Blob tertiaire pour plus de profondeur
                Ellipse()
                    .fill(type.textColor.opacity(0.05))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: 50, y: -50)
                    .animation(.easeInOut(duration: 1.5), value: type)
            } else {
                // Blobs par défaut si aucun type n'est sélectionné
                Circle()
                    .fill(AppTheme.primaryPurple.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 70)
                    .offset(x: -100, y: -180)
                
                Circle()
                    .fill(AppTheme.primaryBlue.opacity(0.08))
                    .frame(width: 350, height: 350)
                    .blur(radius: 80)
                    .offset(x: 120, y: 200)
                
                Ellipse()
                    .fill(AppTheme.lightPink.opacity(0.05))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: 50, y: -50)
            }
        }
    }
}

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            
            // Amélioration: utilisation de smoothing pour un mouvement plus fluide
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self?.x = CGFloat(data.gravity.x) * 30  // Facteur amplifié pour un effet plus marqué
                self?.y = CGFloat(data.gravity.y) * 30
            }
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

struct AnimatedBackground: View {
    @StateObject private var motionManager = MotionManager()
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0
    @State private var colorChange: CGFloat = 0
    
    // Palette de couleurs avec opacité augmentée pour un effet plus visible
    private let colors: [Color] = [
        /*Color(hex: "9933FF").opacity(0.20),*/ // Violet plus visible
        Color(hex: "D4AF37").opacity(0.20), // Or/Jaune plus visible
        Color(hex: "FF6B6B").opacity(0.20), // Rouge plus visible
        Color(hex: "4CAF50").opacity(0.20), // Vert plus visible
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fond blanc de base
                Color.white.edgesIgnoringSafeArea(.all)
                
                // Premier blob avec mouvement accentué
                Circle()
                    .fill(colors[Int(colorChange * 4) % colors.count])
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8) // Taille relative à l'écran
                    .blur(radius: 60)
                    .offset(
                        x: -geometry.size.width * 0.2 + motionManager.x * 5,
                        y: -geometry.size.height * 0.3 + motionManager.y * 5
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: motionManager.x)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: motionManager.y)
                
                // Deuxième blob avec mouvement différent
                Circle()
                    .fill(colors[(Int(colorChange * 4) + 1) % colors.count])
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                    .blur(radius: 70)
                    .offset(
                        x: geometry.size.width * 0.3 + motionManager.x * 8, // Mouvement très accentué
                        y: geometry.size.height * 0.2 + motionManager.y * 8
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: motionManager.x)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: motionManager.y)
                
                // Troisième blob avec effet de retard (pour effet de profondeur)
                Ellipse()
                    .fill(colors[(Int(colorChange * 4) + 2) % colors.count])
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                    .blur(radius: 50)
                    .offset(
                        x: geometry.size.width * 0.1 + motionManager.x * 3,
                        y: -geometry.size.height * 0.1 + motionManager.y * 3
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: motionManager.x) // Animation plus lente
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: motionManager.y)
            }
            .onAppear {
                // Animation lente des couleurs en arrière-plan
                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                    colorChange = 1.0
                }
            }
        }
    }
}
