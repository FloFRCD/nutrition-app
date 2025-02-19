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
    @Binding var dietaryPreferences: [DietaryPreference]
    
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
                
                Text("Préférences alimentaires")
                    .font(.headline)
                
                ForEach(DietaryPreference.allCases, id: \.self) { preference in
                    Toggle(preference.rawValue, isOn: Binding(
                        get: { dietaryPreferences.contains(preference) },
                        set: { isOn in
                            if isOn {
                                dietaryPreferences.append(preference)
                            } else {
                                dietaryPreferences.removeAll { $0 == preference }
                            }
                        }
                    ))
                }
            }
            .padding()
        }
        .padding()
    }
}
