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
                .fill(AppTheme.logoBlue.opacity(0.15))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: 120, y: 200)
                .blendMode(.lighten)
            
            // Effet supplémentaire pour plus de profondeur
            Ellipse()
                .fill(AppTheme.logoYellow.opacity(0.08))
                .frame(width: 250, height: 200)
                .blur(radius: 60)
                .offset(x: 50, y: -50)
                .blendMode(.overlay)
        }
    }
}

//struct AppBackgroundLight: View {
//    var body: some View {
//        ZStack {
//            // Fond principal blanc
//            Color.white.edgesIgnoringSafeArea(.all)
//            
//            // Blob effet 1 - violet clair avec flou
//            Circle()
//                .fill(AppTheme.accent.opacity(0.05))
//                .frame(width: 300, height: 300)
//                .blur(radius: 70)
//                .offset(x: -100, y: -180)
//            
//            // Blob effet 2 - bleu clair avec flou
//            Circle()
//                .fill(AppTheme.primaryBlue.opacity(0.05))
//                .frame(width: 350, height: 350)
//                .blur(radius: 80)
//                .offset(x: 120, y: 200)
//            
//            // Effet supplémentaire pour plus de profondeur
//            Ellipse()
//                .fill(AppTheme.lightPink.opacity(0.03))
//                .frame(width: 250, height: 200)
//                .blur(radius: 60)
//                .offset(x: 50, y: -50)
//        }
//    }
//}

struct AnimatedCircleBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { i in
                Circle()
                    .fill(randomGradient())
                    .frame(width: CGFloat.random(in: 100...200))
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : CGFloat.random(in: -200...200),
                        y: animate ? CGFloat.random(in: -400...400) : CGFloat.random(in: -300...300)
                    )
                    .blur(radius: 40)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 6...10))
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .ignoresSafeArea()
    }

    func randomGradient() -> LinearGradient {
        let colors = [
            [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
            [Color.green.opacity(0.3), Color.yellow.opacity(0.3)],
            [Color.pink.opacity(0.3), Color.orange.opacity(0.3)]
        ]
        let selected = colors.randomElement() ?? [Color.white.opacity(0.2), Color.white.opacity(0.1)]
        return LinearGradient(gradient: Gradient(colors: selected), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}



struct DynamicBackground: View {
    var profileTab: ProfileTab

    var backgroundColor: Color {
        switch profileTab {
        case .info:
            return AppTheme.vibrantGreen
        case .stats:
            return AppTheme.primaryBlue
        case .settings:
            return AppTheme.primaryPurple
        }
    }

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            Circle()
                .fill(backgroundColor.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -100, y: -180)

            Circle()
                .fill(backgroundColor.opacity(0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: 120, y: 200)

            Ellipse()
                .fill(backgroundColor.opacity(0.05))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: 50, y: -50)
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
    @State private var colorChange: CGFloat = 0

    private let colors: [Color] = [
        Color(hex: "FFD54F").opacity(0.2), // Jaune
        Color(hex: "B39DDB").opacity(0.2), // Violet
        Color(hex: "81D4FA").opacity(0.2), // Bleu
        Color(hex: "66BB6A").opacity(0.2), // Vert
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                Circle()
                    .fill(colors[Int(colorChange * 4) % colors.count])
                    .frame(width: geometry.size.width * 0.8)
                    .blur(radius: 60)
                    .offset(x: -geometry.size.width * 0.2 + motionManager.x * 5,
                            y: -geometry.size.height * 0.3 + motionManager.y * 5)

                Circle()
                    .fill(colors[(Int(colorChange * 4) + 1) % colors.count])
                    .frame(width: geometry.size.width * 0.9)
                    .blur(radius: 70)
                    .offset(x: geometry.size.width * 0.3 + motionManager.x * 8,
                            y: geometry.size.height * 0.2 + motionManager.y * 8)

                Ellipse()
                    .fill(colors[(Int(colorChange * 4) + 2) % colors.count])
                    .frame(width: geometry.size.width * 0.6)
                    .blur(radius: 50)
                    .offset(x: geometry.size.width * 0.1 + motionManager.x * 3,
                            y: -geometry.size.height * 0.1 + motionManager.y * 3)
            }
            .onAppear {
                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                    colorChange = 1.0
                }
            }
        }
    }
}


struct AnimatedBackgroundForInit: View {
    @StateObject private var motionManager = MotionManager()
    @State private var colorChange: CGFloat = 0

    // Palette inspirée du logo NutrIA
    private let colors: [Color] = [
        Color(hex: "FFD54F").opacity(0.2), // Jaune pastel
        Color(hex: "B39DDB").opacity(0.2), // Violet pastel
        Color(hex: "81D4FA").opacity(0.2), // Bleu ciel
        Color(hex: "66BB6A").opacity(0.2), // Vert doux
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                // Blob 1
                Circle()
                    .fill(colors[Int(colorChange * 4) % colors.count])
                    .frame(width: geometry.size.width * 0.8)
                    .blur(radius: 60)
                    .offset(
                        x: -geometry.size.width * 0.2 + motionManager.x * 5,
                        y: -geometry.size.height * 0.3 + motionManager.y * 5
                    )

                // Blob 2
                Circle()
                    .fill(colors[(Int(colorChange * 4) + 1) % colors.count])
                    .frame(width: geometry.size.width * 0.9)
                    .blur(radius: 70)
                    .offset(
                        x: geometry.size.width * 0.3 + motionManager.x * 8,
                        y: geometry.size.height * 0.2 + motionManager.y * 8
                    )

                // Blob 3
                Ellipse()
                    .fill(colors[(Int(colorChange * 4) + 2) % colors.count])
                    .frame(width: geometry.size.width * 0.6)
                    .blur(radius: 50)
                    .offset(
                        x: geometry.size.width * 0.1 + motionManager.x * 3,
                        y: -geometry.size.height * 0.1 + motionManager.y * 3
                    )
            }
            .onAppear {
                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                    colorChange = 1.0
                }
            }
        }
    }
}

