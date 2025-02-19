//
//  MeasurementsPage.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct MeasurementsPage: View {
    @Binding var currentWeight: Double
    @Binding var height: Double
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Vos mensurations")
                .font(.title2)
                .bold()
            
            VStack(spacing: 16) {
                HStack {
                    Text("Poids actuel")
                    Spacer()
                    TextField("kg", value: $currentWeight, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                    Text("kg")
                }
                
                HStack {
                    Text("Taille")
                    Spacer()
                    TextField("cm", value: $height, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                    Text("cm")
                }
            }
            .padding()
        }
        .padding()
    }
}
