//
//  Lifestylepage.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct LifestylePage: View {
    @Binding var activityLevel: ActivityLevel
    @Binding var dietaryRestriction: [DietaryRestriction]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Votre mode de vie")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 20) {
                Text("Niveau d'activité")
                    .font(.headline)

                Picker("Niveau d'activité", selection: $activityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                dietaryRestrictionSection()
            }
            .padding()
        }
        .padding()
    }
    
    @ViewBuilder
    private func dietaryRestrictionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Préférences alimentaires")
                .font(.headline)

            ForEach(DietaryRestriction.predefinedCases, id: \.self) { preference in
                Toggle(preference.displayName, isOn: Binding(
                    get: { dietaryRestriction.contains(preference) },
                    set: { isOn in
                        if isOn {
                            dietaryRestriction.append(preference)
                        } else {
                            dietaryRestriction.removeAll { $0 == preference }
                        }
                    }
                ))
            }
        }
    }

}
