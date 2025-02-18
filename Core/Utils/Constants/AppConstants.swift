//
//  AppConstants.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

enum AppConstants {
    static let minimumAge = 13
    static let maximumAge = 100
    static let minimumWeight = 30.0
    static let maximumWeight = 300.0
    
    enum Layout {
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let iconSize: CGFloat = 24
    }
    
    enum Animation {
        static let duration: Double = 0.3
        static let defaultDelay: Double = 0.1
    }
    
    enum Nutrition {
        static let minCalories = 500
        static let maxCalories = 5000
        static let defaultWaterIntake = 2000.0 // ml
    }
}
