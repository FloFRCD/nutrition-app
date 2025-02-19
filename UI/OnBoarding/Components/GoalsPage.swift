//
//  GoalsPage.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI


struct GoalsPage: View {
    @Binding var targetWeight: Double?
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Votre objectif")
                .font(.title2)
                .bold()
            
            VStack(spacing: 16) {
                Toggle("Définir un objectif de poids", isOn: Binding(
                    get: { targetWeight != nil },
                    set: { if !$0 { targetWeight = nil } else { targetWeight = 70 } }
                ))
                
                if targetWeight != nil {
                    HStack {
                        Text("Poids cible")
                        Spacer()
                        TextField("kg", value: $targetWeight, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                        Text("kg")
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}
