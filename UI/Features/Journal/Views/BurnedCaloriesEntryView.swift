//
//  BurnedCaloriesEntryView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation
import SwiftUI


struct BurnedCaloriesEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    @State private var calories: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Calories brûlées") {
                    TextField("Ex: 300", text: $calories)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Activité physique")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider") {
                        if let value = Double(calories) {
                            viewModel.setBurnedCalories(value, for: viewModel.selectedDate)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}
