//
//  AnimatedSplashView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation
import SwiftUI

struct AnimatedSplashView: View {
    @Binding var isActive: Bool
    @State private var animate = false

    var body: some View {
        ZStack {
            AnimatedCircleBackground() // Fond animé avec des cercles

            VStack(spacing: 16) {
                Image("Icon-scan")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1 : 0)

                Text("Nutria")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .opacity(animate ? 1 : 0)

                // ✅ Slogan ajouté
                Text("Votre nutrition. Vos objectifs. Votre app.")
                    .font(.callout)
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .bold()
                    .italic(animate)
                    .opacity(animate ? 1 : 0)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animate = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isActive = false
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
