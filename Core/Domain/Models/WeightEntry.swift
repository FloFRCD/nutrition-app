//
//  WeightEntry.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct WeightEntry: Identifiable {
    var id = UUID()
    let date: Date
    let weight: Double
    let note: String?
    
    init(id: UUID = UUID(), date: Date, weight: Double, note: String? = nil) {
        self.id = id
        self.date = date
        self.weight = weight
        self.note = note
    }
}
