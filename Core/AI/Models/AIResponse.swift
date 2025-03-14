//
//  AIResponse.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation

// Structures pour le parsing de la réponse JSON
struct AIMealPlanResponse: Codable {
    let meal_suggestions: [AIMeal]
}

struct AIMeal: Codable, Identifiable, Hashable {
    // Déclaré avec `var` et valeur par défaut, donc ne sera pas requis dans le JSON
    var id = UUID()
    
    let name: String
    let description: String
    let type: String
    
    // CodingKeys pour indiquer quels champs appartiennent au JSON
    enum CodingKeys: String, CodingKey {
        case name, description, type
        // Pas d'id ici car il n'est pas dans le JSON
    }
    
    // Implémentation de Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implémentation de Equatable
    static func == (lhs: AIMeal, rhs: AIMeal) -> Bool {
        return lhs.id == rhs.id
    }
}


