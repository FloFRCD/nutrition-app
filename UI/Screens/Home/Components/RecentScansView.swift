//
//  RecentScansView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI


struct RecentScansView: View {
    let scans: [FoodScan]
    
    var body: some View {
        if scans.isEmpty {
            EmptyRecentScansView()
        } else {
            FilledRecentScansView(scans: scans) // Ici nous passons les scans
        }
    }
}

private struct FilledRecentScansView: View {
    let scans: [FoodScan] // Nous devons déclarer la propriété
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Derniers aliments scannés")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(scans) { scan in
                    FoodScanItem(
                        name: scan.foodName,  // Utilisez directement foodName
                        calories: "\(Int(scan.nutritionInfo.calories))",  // Accédez aux calories via nutritionInfo
                        time: formatDate(scan.date)
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private func formatDate(_ date: Date) -> String {
        // Calcul du temps écoulé
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "Il y a \(minutes) min"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "Il y a \(hours)h"
        } else {
            let days = Int(interval / 86400)
            return "Il y a \(days)j"
        }
    }
}

// Vue vide pour Recent Scans
struct EmptyRecentScansView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Derniers aliments scannés")
                .font(.headline)
            
            VStack(alignment: .center, spacing: 12) {
                Image(systemName: "camera.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Commencez à scanner vos aliments")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                NavigationLink(destination: ScanView()) {
                    Text("Scanner un aliment")
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}
