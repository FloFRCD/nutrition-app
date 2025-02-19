//
//  MealCard.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct MealCard: View {
    let mealTime: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(mealTime)
                .font(.headline)
            Text("Aucun repas planifié")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
#Preview {
    MealCard(mealTime: "Dîner")
}
