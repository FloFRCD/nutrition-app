//
//  AddWeightTodayView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 03/04/2025.
//

import Foundation
import SwiftUI

struct AddWeightTodayView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var weight: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // Titre
            Text("Ajouter le poids du jour")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top)

            // Champ texte
            TextField("Poids en kg", text: $weight)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

            // Bouton d’enregistrement
            Button(action: saveWeight) {
                Text("Enregistrer")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground))
    }

    private func saveWeight() {
        guard let value = Double(weight.replacingOccurrences(of: ",", with: ".")) else { return }
        LocalDataManager.shared.saveWeight(value)
        dismiss()
        NotificationCenter.default.post(name: .weightDataDidChange, object: nil)
    }
}

