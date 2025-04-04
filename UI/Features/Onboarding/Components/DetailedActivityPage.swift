//
//  DetailedActivityPage.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 08/03/2025.
//

import Foundation
import SwiftUI


struct DetailedActivityPage: View {
    @Binding var exerciseDaysPerWeek: Int
    @Binding var exerciseDuration: Int
    @Binding var exerciseIntensity: ExerciseIntensity
    @Binding var jobActivity: JobActivityLevel
    @Binding var dailyActivity: DailyActivityLevel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Votre activité physique")
                .font(.title2)
                .bold()
                .padding(.bottom)
            
            // Jours d'exercice par semaine
            VStack(alignment: .leading) {
                Text("Combien de jours faites-vous de l'exercice par semaine ?")
                    .font(.headline)
                Stepper("\(exerciseDaysPerWeek) jour(s)", value: $exerciseDaysPerWeek, in: 0...7)
            }
            
            // Durée d'exercice
            VStack(alignment: .leading) {
                Text("Durée moyenne d'une séance d'exercice :")
                    .font(.headline)
                Stepper("\(exerciseDuration) minutes", value: $exerciseDuration, in: 0...180, step: 15)
            }
            
            // Intensité d'exercice
            VStack(alignment: .leading) {
                Text("Intensité de vos exercices :")
                    .font(.headline)
                Picker("Intensité", selection: $exerciseIntensity) {
                    Text("Légère (marche, yoga doux)").tag(ExerciseIntensity.light)
                    Text("Modérée (jogging, vélo)").tag(ExerciseIntensity.moderate)
                    Text("Intense (sprint, crossfit)").tag(ExerciseIntensity.intense)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Activité professionnelle
            VStack(alignment: .leading) {
                Text("Votre activité professionnelle :")
                    .font(.headline)
                Picker("Travail", selection: $jobActivity) {
                    Text("Assis la plupart du temps").tag(JobActivityLevel.seated)
                    Text("Debout la plupart du temps").tag(JobActivityLevel.standing)
                    Text("Activité physique modérée").tag(JobActivityLevel.physical)
                    Text("Travail physique intense").tag(JobActivityLevel.heavyPhysical)
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Activité quotidienne
            VStack(alignment: .leading) {
                Text("Niveau de déplacement quotidien :")
                    .font(.headline)
                Picker("Déplacements", selection: $dailyActivity) {
                    Text("Minimal (peu de marche)").tag(DailyActivityLevel.minimal)
                    Text("Modéré (marche régulière)").tag(DailyActivityLevel.moderate)
                    Text("Actif (marche fréquente, vélo)").tag(DailyActivityLevel.active)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Spacer()
        }
        .padding()
    }
}
