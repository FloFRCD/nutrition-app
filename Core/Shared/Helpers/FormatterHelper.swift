//
//  FormatterHelper.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

struct FormatterHelper {
    static func formatWeight(_ weight: Double) -> String {
        String(format: "%.1f kg", weight)
    }
    
    static func formatCalories(_ calories: Int) -> String {
        "\(calories) kcal"
    }
    
    static func formatMacro(_ value: Double) -> String {
        String(format: "%.1f g", value)
    }
    
    static func formatPercentage(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }
}

extension JSONEncoder {
    static var iso8601: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var iso8601: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

