//
//  RecentFoodScanView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 29/03/2025.
//

import Foundation
import SwiftUI


struct RecentFoodScansView: View {
    @ObservedObject var localDataManager = LocalDataManager.shared
    @EnvironmentObject var journalViewModel: JournalViewModel
    var mealType: MealType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Derniers aliments scannés")
                .font(.headline)
                .padding(.horizontal)
            
            if localDataManager.recentScans.isEmpty {
                // Vue "pas de scans"
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(localDataManager.getRecentFoodScans()) { scan in
                            // ⚠️ PROBLÈME PROBABLE ICI ⚠️
                            // Vérifiez si cette partie appelle addScanToJournal directement
                            // au lieu de l'attacher à un bouton
                            Button {
                                // C'est ici que la fonction devrait être appelée
                                addScanToJournal(scan)
                            } label: {
                                RecentFoodScanCard(scan: scan)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func addScanToJournal(_ scan: FoodScan) {
        print("📝 Ajout au journal du scan: \(scan.id) - \(scan.foodName)")
        // Créer un Food à partir du scan
        let food = Food(
            id: UUID(),
            name: scan.foodName,
            calories: Int(scan.nutritionInfo.calories),
            proteins: scan.nutritionInfo.proteins,
            carbs: scan.nutritionInfo.carbs,
            fats: scan.nutritionInfo.fats,
            fiber: scan.nutritionInfo.fiber,
            servingSize: 1,
            servingUnit: .piece,
            image: nil
        )
        
        // Créer une entrée pour le journal
        let entry = FoodEntry(
            id: UUID(),
            food: food,
            quantity: 1,
            date: journalViewModel.selectedDate,
            mealType: mealType,
            source: .foodPhoto,
            unit: food.servingUnit.rawValue
        )
        
        // Ajouter l'entrée
        journalViewModel.addFoodEntry(entry)
    }
}

struct RecentFoodScanCard: View {
    let scan: FoodScan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(scan.foodName)
                .font(.headline)
                .lineLimit(1)
            
            Text("\(Int(scan.nutritionInfo.calories)) kcal")
                .font(.subheadline)
                .foregroundColor(.orange)
            
            HStack(spacing: 8) {
                MacronutrientLabel(value: scan.nutritionInfo.proteins, label: "P", color: .blue)
                MacronutrientLabel(value: scan.nutritionInfo.carbs, label: "G", color: .green)
                MacronutrientLabel(value: scan.nutritionInfo.fats, label: "L", color: .red)
            }
            
            HStack {
                Text(scan.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(scan.mealType.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct MacronutrientLabel: View {
    let value: Double
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Int(value))g")
                .font(.caption)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
