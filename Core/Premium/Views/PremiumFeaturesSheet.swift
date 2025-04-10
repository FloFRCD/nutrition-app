//
//  PremiumFeaturesSheet.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 10/04/2025.
//

import Foundation
import SwiftUI

import SwiftUI

struct PremiumFeaturesSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Text("Fonctionnalités Premium")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    FeatureItem("Accès à l’intelligence artificielle la plus avancée")
                    FeatureItem("Analyse automatique des plats via photo")
                    FeatureItem("Scan des aliments via le code-barres")
                    FeatureItem("Suggestions de plats ultra-personnalisées")
                    FeatureItem("Recettes générées selon tes préférences")
                    FeatureItem("Liste de courses intelligente et personnalisable")
                    FeatureItem("Accès anticipé aux nouvelles fonctionnalités")
                }
                .padding(.vertical)

                Spacer()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func FeatureItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.body)
            Text(text)
                .foregroundColor(.white)
                .font(.body)
        }
    }
}
