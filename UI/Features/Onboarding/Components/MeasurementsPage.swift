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
    @Binding var bodyFatPercentage: Double?
    
    var bmi: Double {
        let heightInMeters = height / 100
        return currentWeight / (heightInMeters * heightInMeters)
    }
    
    var estimatedLeanMass: Double? {
            guard let fatPercentage = bodyFatPercentage else {
                return nil
            }
            return currentWeight * (1 - fatPercentage / 100)
        }
    
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
                
                Toggle("Je connais mon % de masse graisseuse", isOn: Binding(
                    get: { bodyFatPercentage != nil },
                    set: { if !$0 { bodyFatPercentage = nil } else { bodyFatPercentage = 20 } }
                ))
                
                if bodyFatPercentage != nil {
                    HStack {
                        Text("% de masse graisseuse")
                        Spacer()
                        TextField("%", value: Binding(
                            get: { bodyFatPercentage ?? 20 },
                            set: { bodyFatPercentage = $0 }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                        Text("%")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                                Text("IMC: \(bmi, specifier: "%.1f")")
                                    .font(.subheadline)
                                
                                // N'afficher la masse maigre que si on a le pourcentage
                                if let leanMass = estimatedLeanMass {
                                    Text("Masse maigre estimée: \(leanMass, specifier: "%.1f") kg")
                                        .font(.subheadline)
                                }
                            }
                            .padding(.top)
            }
            .padding()
        }
        .padding()
    }
}

