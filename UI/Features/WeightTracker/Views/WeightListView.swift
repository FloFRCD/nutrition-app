//
//  WeightListView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 03/04/2025.
//

import SwiftUI
import CoreData

struct WeightListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightRecord.date, ascending: false)],
        animation: .default
    )
    private var weightRecords: FetchedResults<WeightRecord>

    @State private var selectedDate = Date()
    @State private var weight: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Titre + Fermer
                HStack {
                    Button("Fermer") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.accentColor)

                    Spacer()

                    Text("Historique du poids")
                        .font(.headline)
                        .foregroundColor(AppTheme.accent)

                    Spacer()
                    Text(" ").frame(width: 60)
                }
                .padding(.horizontal)

                // Formulaire d’ajout
                HStack {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()

                    TextField("Poids (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal)
                        .frame(height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Button(action: saveWeight) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.accent)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Liste des poids avec suppression
                List {
                    ForEach(weightRecords) { record in
                        HStack {
                            Text(formattedDate(record.date))
                            Spacer()
                            Text(String(format: "%.1f kg", record.weight))
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.accent)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteWeight)
                }
                .scrollContentBackground(.hidden)
                .background(Color.white)
            }
            .padding(.top)
        }
    }

    // Formatage date
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Sauvegarde
    private func saveWeight() {
        guard let value = Double(weight.replacingOccurrences(of: ",", with: ".")) else { return }

        let newEntry = WeightRecord(context: viewContext)
        newEntry.date = Calendar.current.startOfDay(for: selectedDate)
        newEntry.weight = value

        do {
            try viewContext.save()
            weight = ""
        } catch {
            print("❌ Erreur lors de l’enregistrement du poids :", error)
        }
    }

    private func deleteWeight(at offsets: IndexSet) {
        for index in offsets {
            let record = weightRecords[index]
            viewContext.delete(record)
        }

        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .weightDataDidChange, object: nil)
        } catch {
            print("Erreur lors de la suppression :", error)
        }
    }
}





