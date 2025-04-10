//
//  ProfileIconView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 02/04/2025.
//


import SwiftUI
import Lottie

struct LottieProfileIcon: UIViewRepresentable {
    @Binding var play: Bool

    class Coordinator {
        var animationView: LottieAnimationView?

        init(animationView: LottieAnimationView?) {
            self.animationView = animationView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(animationView: nil)
    }

    func makeUIView(context: Context) -> UIView {
        let animationView = LottieAnimationView(name: "profile-animation")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        context.coordinator.animationView = animationView
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard play, let animationView = context.coordinator.animationView else { return }

        animationView.stop()
        animationView.currentProgress = 0
        animationView.play { _ in
            DispatchQueue.main.async {
                self.play = false
            }
        }
    }
}
