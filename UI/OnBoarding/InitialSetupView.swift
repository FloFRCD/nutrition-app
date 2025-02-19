//
//  InitialSetupView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct InitialSetupView: View {
    @StateObject private var viewModel = InitialSetupViewModel()
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentPage) {
                // Page 1: Informations personnelles
                PersonalInfoPage(
                    name: $viewModel.name,
                    birthDate: $viewModel.birthDate,
                    gender: $viewModel.gender
                )
                .tag(0)
                
                // Page 2: Mensurations
                MeasurementsPage(
                    currentWeight: $viewModel.currentWeight,
                    height: $viewModel.height
                )
                .tag(1)
                
                // Page 3: Mode de vie
                LifestylePage(
                    activityLevel: $viewModel.activityLevel,
                    dietaryPreferences: $viewModel.dietaryPreferences
                )
                .tag(2)
                
                // Page 4: Objectifs
                GoalsPage(targetWeight: $viewModel.targetWeight)
                .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .overlay(
                NavigationControls(
                    currentPage: $currentPage,
                    isLastPage: currentPage == 3,
                    canProceed: viewModel.canProceedFromCurrentPage(currentPage),
                    onComplete: {
                        Task {
                            await viewModel.completeSetup()
                        }
                    }
                )
                , alignment: .bottom
            )
            .navigationTitle("Configuration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


