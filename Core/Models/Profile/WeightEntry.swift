//
//  WeightEntry.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct WeightEntry: Identifiable, Codable {
    let id: UUID
    var weight: Double
    var date: Date
    var note: String?
}
