//
//  Achievement.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var icon: String
    
    init(id: UUID = UUID(), name: String, description: String, icon: String, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}
