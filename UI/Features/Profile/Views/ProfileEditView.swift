//
//  ProfileEditView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/02/2025.
//

import Foundation
import SwiftUI

// Sous-vue pour les informations personnelles
struct PersonalInfoSectionView: View {
    @Binding var name: String
    @Binding var birthDate: Date
    @Binding var gender: Gender
    
    var body: some View {
        Section(header: Text("Informations personnelles")) {
            TextField("Prénom", text: $name)
            DatePicker("Date de naissance", selection: $birthDate, displayedComponents: .date)
            Picker("Genre", selection: $gender) {
                // Au lieu d'utiliser allCases, on liste manuellement les valeurs possibles
                ForEach(genderValues(), id: \.self) { gender in
                    Text(gender.rawValue)
                }
            }
        }
    }
    
    // Cette fonction retourne les valeurs possibles de l'énumération
    private func genderValues() -> [Gender] {
        // Remplacez ces valeurs par les véritables options de votre énumération
        return [.male, .female, .other] // À adapter selon vos valeurs réelles
    }
}

// Sous-vue pour les mensurations
struct MeasurementsSectionView: View {
    @Binding var weight: Double
    @Binding var height: Double
    @Binding var bodyFatPercentage: Double?
    @Binding var showBodyFat: Bool
    
    var body: some View {
        Section(header: Text("Mensurations")) {
            HStack {
                Text("Poids actuel")
                Spacer()
                TextField("Poids", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("kg")
            }
            HStack {
                Text("Taille")
                Spacer()
                TextField("Taille", value: $height, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("cm")
            }

            Toggle("Je connais mon % de masse graisseuse", isOn: $showBodyFat.animation())
            if showBodyFat {
                HStack {
                    Text("% Masse graisseuse")
                    Spacer()
                    TextField("%", value: Binding(
                        get: { bodyFatPercentage ?? 20 },
                        set: { bodyFatPercentage = $0 }),
                        format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

// Sous-vue pour l'objectif
struct GoalSectionView: View {
    @Binding var selectedGoal: FitnessGoal
    
    var body: some View {
        Section(header: Text("Objectif")) {
            Picker("Objectif", selection: $selectedGoal) {
                // Au lieu d'utiliser allCases, on liste manuellement les valeurs possibles
                ForEach(fitnessGoalValues(), id: \.self) { goal in
                    Text(goal.rawValue)
                }
            }
        }
    }
    
    // Cette fonction retourne les valeurs possibles de l'énumération
    private func fitnessGoalValues() -> [FitnessGoal] {
        // Remplacez ces valeurs par les véritables options de votre énumération
        return [.loseWeight, .maintainWeight, .gainMuscle] // À adapter selon vos valeurs réelles
    }
}

// Sous-vue pour les activités physiques
struct ActivitySectionView: View {
    @Binding var exerciseDaysPerWeek: Int
    @Binding var exerciseDuration: Int
    @Binding var exerciseIntensity: ExerciseIntensity
    @Binding var jobActivity: JobActivityLevel
    @Binding var dailyActivity: DailyActivityLevel
    
    var body: some View {
        Section(header: Text("Activités physiques")) {
            Stepper("Jours d'entraînement/semaine: \(exerciseDaysPerWeek)", value: $exerciseDaysPerWeek, in: 0...7)
            Stepper("Durée moyenne (min): \(exerciseDuration)", value: $exerciseDuration, in: 0...180, step: 5)
            
            IntensityPickerView(exerciseIntensity: $exerciseIntensity)
            JobActivityPickerView(jobActivity: $jobActivity)
            DailyActivityPickerView(dailyActivity: $dailyActivity)
        }
    }
}

// Sous-vue pour l'intensité d'exercice
struct IntensityPickerView: View {
    @Binding var exerciseIntensity: ExerciseIntensity
    
    var body: some View {
        Picker("Intensité", selection: $exerciseIntensity) {
            // Au lieu d'utiliser allCases, on liste manuellement les valeurs possibles
            ForEach(exerciseIntensityValues(), id: \.self) { level in
                Text(level.rawValue.capitalized).tag(level)
            }
        }
    }
    
    // Cette fonction retourne les valeurs possibles de l'énumération
    private func exerciseIntensityValues() -> [ExerciseIntensity] {
        // Remplacez ces valeurs par les véritables options de votre énumération
        // Par exemple, si vous avez faible, modéré, intense, etc.
        return [.light, .moderate, .intense] // À adapter selon vos valeurs réelles
    }
}

// Sous-vue pour l'activité au travail
struct JobActivityPickerView: View {
    @Binding var jobActivity: JobActivityLevel
    
    var body: some View {
        Picker("Activité au travail", selection: $jobActivity) {
            // Au lieu d'utiliser allCases, on liste manuellement les valeurs possibles
            ForEach(jobActivityValues(), id: \.self) { level in
                Text(level.rawValue.capitalized).tag(level)
            }
        }
    }
    
    // Cette fonction retourne les valeurs possibles de l'énumération
    private func jobActivityValues() -> [JobActivityLevel] {
        // Remplacez ces valeurs par les véritables options de votre énumération
        return [.seated, .standing, .physical, .heavyPhysical] // À adapter selon vos valeurs réelles
    }
}

// Sous-vue pour l'activité quotidienne
struct DailyActivityPickerView: View {
    @Binding var dailyActivity: DailyActivityLevel
    
    var body: some View {
        Picker("Activité quotidienne", selection: $dailyActivity) {
            // Au lieu d'utiliser allCases, on liste manuellement les valeurs possibles
            ForEach(dailyActivityValues(), id: \.self) { level in
                Text(level.rawValue.capitalized).tag(level)
            }
        }
    }
    
    // Cette fonction retourne les valeurs possibles de l'énumération
    private func dailyActivityValues() -> [DailyActivityLevel] {
        // Remplacez ces valeurs par les véritables options de votre énumération
        return [.minimal, .active, .moderate] // À adapter selon vos valeurs réelles
    }
}

// Vue principale
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localDataManager: LocalDataManager

    @State private var name: String
    @State private var birthDate: Date
    @State private var gender: Gender
    @State private var weight: Double
    @State private var height: Double
    @State private var bodyFatPercentage: Double?
    @State private var showBodyFat: Bool
    @State private var selectedGoal: FitnessGoal

    // Détails d'activité
    @State private var exerciseDaysPerWeek: Int
    @State private var exerciseDuration: Int
    @State private var exerciseIntensity: ExerciseIntensity
    @State private var jobActivity: JobActivityLevel
    @State private var dailyActivity: DailyActivityLevel

    @State private var showAlert = false

    init(userProfile: UserProfile) {
        _name = State(initialValue: userProfile.name)
        _birthDate = State(initialValue: Calendar.current.date(byAdding: .year, value: -userProfile.age, to: Date()) ?? Date())
        _gender = State(initialValue: userProfile.gender)
        _weight = State(initialValue: userProfile.weight)
        _height = State(initialValue: userProfile.height)
        _bodyFatPercentage = State(initialValue: userProfile.bodyFatPercentage)
        _showBodyFat = State(initialValue: userProfile.bodyFatPercentage != nil)
        _selectedGoal = State(initialValue: userProfile.fitnessGoal)

        let details = userProfile.activityDetails ?? ActivityDetails()
        _exerciseDaysPerWeek = State(initialValue: details.exerciseDaysPerWeek)
        _exerciseDuration = State(initialValue: details.exerciseDuration)
        _exerciseIntensity = State(initialValue: details.exerciseIntensity)
        _jobActivity = State(initialValue: details.jobActivity)
        _dailyActivity = State(initialValue: details.dailyActivity)
    }

    var body: some View {
        NavigationView {
            Form {
                PersonalInfoSectionView(
                    name: $name,
                    birthDate: $birthDate,
                    gender: $gender
                )
                
                MeasurementsSectionView(
                    weight: $weight,
                    height: $height,
                    bodyFatPercentage: $bodyFatPercentage,
                    showBodyFat: $showBodyFat
                )
                
                GoalSectionView(selectedGoal: $selectedGoal)
                
                ActivitySectionView(
                    exerciseDaysPerWeek: $exerciseDaysPerWeek,
                    exerciseDuration: $exerciseDuration,
                    exerciseIntensity: $exerciseIntensity,
                    jobActivity: $jobActivity,
                    dailyActivity: $dailyActivity
                )
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveProfile()
                    }
                }
            }
            .alert("Erreur", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Veuillez vérifier les valeurs saisies")
            }
        }
    }

    private func saveProfile() {
        guard weight > 0 && height > 0 && (!showBodyFat || ((bodyFatPercentage ?? 0) >= 0 && (bodyFatPercentage ?? 0) <= 100)) else {
            showAlert = true
            return
        }

        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        let details = ActivityDetails(
            exerciseDaysPerWeek: exerciseDaysPerWeek,
            exerciseDuration: exerciseDuration,
            exerciseIntensity: exerciseIntensity,
            jobActivity: jobActivity,
            dailyActivity: dailyActivity
        )

        if var profile = localDataManager.userProfile {
            profile.name = name
            profile.age = age
            profile.gender = gender
            profile.weight = weight
            profile.height = height
            profile.bodyFatPercentage = showBodyFat ? bodyFatPercentage : nil
            profile.fitnessGoal = selectedGoal
            profile.activityDetails = details

            Task {
                try? await localDataManager.save(profile, forKey: "userProfile")
                await MainActor.run {
                    localDataManager.userProfile = profile
                    dismiss()
                }
            }
        }
    }
}
