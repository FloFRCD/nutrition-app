//
//  SuggestionView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation
import SwiftUI
import MessageUI

struct SuggestionView: View {
    @State private var showMail = false
    @State private var showAlert = false

    var body: some View {
        VStack {
            Image(systemName: "lightbulb")
                .resizable()
                .frame(width: 48, height: 75)
                .foregroundColor(AppTheme.logoYellow)
                .padding(.top)

            Text("Une idée pour améliorer NutrIA ? 💡")
                .font(.title3)
                .bold()
                .padding(.top, 8)

            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                Text("Tu as une idée ou un retour pour améliorer NutrIA ? Appuie sur le bouton ci-dessous pour nous envoyer un message directement par mail.")
                    .font(.body)
                    .foregroundColor(.secondary)

                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        showMail = true
                    } else {
                        showAlert = true
                    }
                }) {
                    Text("Envoyer une suggestion")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Suggestion")
        .sheet(isPresented: $showMail) {
            MailView(
                recipients: ["Suggestions.Nutria@proton.me"],
                subject: "Suggestion utilisateur NutrIA iOS",
                body: ""
            )
        }
        .alert("Mail non configuré sur cet appareil", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}


