//
//  WeightTrackerView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUICore
import SwiftUI

struct WeightTrackerView: View {
    @StateObject private var viewModel = WeightTrackerViewModel()
    
    var body: some View {
        VStack {
            // Graphique d'évolution du poids
            if !viewModel.weightEntries.isEmpty {
                // Ici viendra le graphique
                Text("Graphique à implémenter")
            }
            
            List(viewModel.weightEntries) { entry in
                HStack {
                    Text(entry.date, style: .date)
                    Spacer()
                    Text("\(entry.weight, specifier: "%.1f") kg")
                }
            }
            
            Button("Ajouter une pesée") {
                viewModel.showingAddEntry = true
            }
        }
        .sheet(isPresented: $viewModel.showingAddEntry) {
            // Vue d'ajout de poids
            Text("Formulaire d'ajout à implémenter")
        }
    }
}
