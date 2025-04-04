//
//  PersonalInfoPage.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct PersonalInfoPage: View {
    @Binding var name: String
    @Binding var birthDate: Date
    @Binding var gender: Gender
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Commençons par faire connaissance")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                TextField("Nom complet", text: $name)
                    .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit {
                            hideKeyboard()
                        }
                
                DatePicker("Date de naissance",
                          selection: $birthDate,
                          displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                Picker("Genre", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
        }
        .padding()
    }
}


