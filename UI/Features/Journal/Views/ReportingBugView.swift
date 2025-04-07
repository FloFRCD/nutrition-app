//
//  ReportingBugView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 07/04/2025.
//

import Foundation
import SwiftUI
import MessageUI


struct ReportingBugView: View {
    @State private var showMail = false
    @State private var showAlert = false

    var body: some View {
        
        Image(systemName: "ladybug")
            .resizable()
            .frame(width: 75, height: 75)
            .foregroundColor(Color.red)
            .multilineTextAlignment(.center)
            .padding(.top)
        
        Spacer()
        
        VStack(alignment: .leading, spacing: 24) {
            

            Text("Tu rencontre un bug ? Appuie sur le bouton ci-dessous pour nous envoyer un message directement par mail.")
                .font(.body)
                .foregroundColor(.secondary)

            Button(action: {
                if MFMailComposeViewController.canSendMail() {
                    showMail = true
                } else {
                    showAlert = true
                }
            }) {
                Text("Signaler")
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
        .navigationTitle("Signaler un bug")
        .sheet(isPresented: $showMail) {
            MailView(
                recipients: ["Suggestions.Nutria@proton.me"],
                subject: "BUG utilisateur NutrIA iOS",
                body: ""
            )
        }
        .alert("Mail non configuré sur cet appareil", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
