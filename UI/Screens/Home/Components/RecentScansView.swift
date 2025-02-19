//
//  RecentScansView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct RecentScansView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Derniers aliments scannés")
                .font(.headline)
            
            VStack(spacing: 8) {
                FoodScanItem(name: "Yaourt grec", calories: "120", time: "Il y a 2h")
                FoodScanItem(name: "Pomme", calories: "95", time: "Il y a 4h")
                FoodScanItem(name: "Pain complet", calories: "80", time: "Il y a 5h")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
#Preview {
    RecentScansView()
}
