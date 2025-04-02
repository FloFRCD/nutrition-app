//
//  WeightTrackerViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

class WeightTrackerViewModel: ObservableObject {
    @Published var weightEntries: [WeightEntry] = []
    @Published var showingAddEntry = false
    
    func addWeightEntry(_ weight: Double) {
        let entry = WeightEntry(id: UUID(), date: Date(), weight: weight)
        weightEntries.append(entry)
        // Sauvegarder dans LocalDataManager
    }
    
    func fetchWeightEntries() {
        // Charger depuis LocalDataManager
    }
}
