//
//  InitialSetupView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

import SwiftUI

@available(iOS 18.0, *)
struct InitialSetupView: View {
    @StateObject private var viewModel = InitialSetupViewModel()
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            AnimatedBackgroundForInit()

            VStack {
                
                Image("Icon-scan")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .padding(.top, 50)
                Text("Nutria")
                    
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                Text("Votre nutrition. Vos objectifs. Votre app.")
                    .font(.subheadline)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                TabView(selection: $currentPage) {
                    PersonalInfoPage(
                        name: $viewModel.name,
                        birthDate: $viewModel.birthDate,
                        gender: $viewModel.gender
                    )
                    .background(Color.clear)
                    .tag(0)

                    MeasurementsPage(
                        currentWeight: $viewModel.currentWeight,
                        height: $viewModel.height,
                        bodyFatPercentage: $viewModel.bodyFatPercentage
                    )
                    .background(Color.clear)
                    .tag(1)

                    DetailedActivityPage(
                        exerciseDaysPerWeek: $viewModel.exerciseDaysPerWeek,
                        exerciseDuration: $viewModel.exerciseDuration,
                        exerciseIntensity: $viewModel.exerciseIntensity,
                        jobActivity: $viewModel.jobActivity,
                        dailyActivity: $viewModel.dailyActivity
                    )
                    .background(Color.clear)
                    .tag(2)

                    GoalsPage(selectedGoal: $viewModel.fitnessGoal)
                        .background(Color.clear)
                        .tag(3)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .padding(.top)

                NavigationControls(
                    currentPage: $currentPage,
                    isLastPage: currentPage == 3,
                    canProceed: viewModel.canProceedFromCurrentPage(currentPage),
                    onComplete: {
                        Task {
                            try await viewModel.completeSetup()
                        }
                    }
                )
                .padding(.bottom)
            }
        }
        .navigationBarHidden(true)
    }
}


