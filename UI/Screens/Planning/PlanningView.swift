//
//  PlanningView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct PlanningView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(["Petit-déjeuner", "Déjeuner", "Dîner"], id: \.self) { meal in
                        MealCard(mealTime: meal)
                    }
                }
                .padding()
            }
            .navigationTitle("Planning")
        }
    }
}
#Preview {
    PlanningView() 
}
