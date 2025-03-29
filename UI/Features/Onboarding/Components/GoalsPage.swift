//
//  GoalsPage.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI


struct GoalsPage: View {
    @Binding var selectedGoal: FitnessGoal
    var isValid: Bool {
            return true
        }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Votre objectif")
                .font(.title2)
                .bold()
            
            VStack(spacing: 16) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    Button(action: {
                        selectedGoal = goal
                        print("Objectif sélectionné : \(goal)") // Debug
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.rawValue)
                                    .font(.headline)
                            }
                            Spacer()
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedGoal == goal ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .padding()
        .onChange(of: selectedGoal) { _ in
                    print("Changement d'objectif détecté") // Debug
                }
    }
}
