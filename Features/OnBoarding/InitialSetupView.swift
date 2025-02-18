//
//  InitialSetupView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct InitialSetupView: View {
    @StateObject private var viewModel = InitialSetupViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    VStack {
                        TextField("Nom", text: $viewModel.name)
                        
                        Picker("Sexe", selection: $viewModel.gender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }
                    }
                }, header: {
                    Text("Informations personnelles")
                })
            }
            .navigationTitle("Configuration initiale")
        }
    }
}
