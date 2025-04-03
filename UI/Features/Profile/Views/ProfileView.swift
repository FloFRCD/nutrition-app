//
//  ProfileView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI
import Charts

struct ProfileView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @ObservedObject private var localDataManager = LocalDataManager.shared
    @State private var showingEditProfile = false
    @State private var selectedTab: ProfileTab = .info
    @State private var showHealthKitPermissions = false
    @Binding var isTabBarVisible: Bool
    @EnvironmentObject var tabBarSettings: TabBarSettings
    
    @State private var editedWeight: String = ""
    @State private var editedTargetWeight: String = ""
    
    @State private var showWeight = true
    @State private var showConsumed = true
    @State private var showBurned = true
    @State private var showWeightListView = false
    @State private var showAddWeightSheet = false
    @State private var showWeightList = false


    
    var body: some View {
        NavigationStack {
            ZStack {
                DynamicBackground(profileTab: selectedTab).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header avec photo et info principale
                    if let profile = localDataManager.userProfile {
                        headerView(profile: profile)
                    }
                    
                    // Tabs
                    profileTabView()
                    
                    // Content based on selected tab
                    ScrollView {
                        if let profile = localDataManager.userProfile {
                            switch selectedTab {
                            case .info:
                                profileInfoContent(profile: profile)
                            case .stats:
                                statsContent(profile: profile)
                            case .settings:
                                settingsContent()
                            }
                        }
                    }
                    .refreshable {
                    }
                }
            }
            .navigationTitle("") // <- vide pour ne rien afficher
                .navigationBarTitleDisplayMode(.inline)

                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingEditProfile = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                }
            
                .sheet(isPresented: $showingEditProfile) {
                if let profile = localDataManager.userProfile {
                    ProfileEditView(userProfile: profile)
                        .preferredColorScheme(.light)
                        .accentColor(AppTheme.accent)
                }
            }
            .sheet(isPresented: $showHealthKitPermissions) {
                HealthKitPermissionsView()
            }
            .foregroundColor(Color.black)

        }
        .onAppear {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
            editedWeight = String(format: "%.1f", localDataManager.userProfile?.weight ?? 0)
            editedTargetWeight = String(format: "%.1f", localDataManager.userProfile?.targetWeight ?? 0)
        }
        .onDisappear {
            NotificationCenter.default.post(name: .showTabBar, object: nil)
        }
        .accentColor(AppTheme.accent)
        .preferredColorScheme(.light)
    }
    
    // Header avec photo et info principale
    private func headerView(profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            // Photo et nom
            VStack(spacing: 8) {
                // Photo de profil avec badge de progrès
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .overlay(
                            ZStack {
                                // Cercle de progression
                                Circle()
                                    .stroke(
                                        Color.gray.opacity(0.2),
                                        lineWidth: 8
                                    )
                                
                                // Progression actuelle
                                Circle()
                                    .trim(from: 0, to: calculateProgressToGoal(profile: profile))
                                    .stroke(
                                        AppTheme.progressGradient,
                                        style: StrokeStyle(
                                            lineWidth: 8,
                                            lineCap: .round
                                        )
                                    )
                                    .rotationEffect(.degrees(-90))
                            }
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.secondaryText)
                        )
                }
                
                // Nom et objectif
                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Objectif: \(profile.fitnessGoal.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Quick stats
            HStack(spacing: 20) {
                quickStatItem(label: "Poids", value: "\(Int(profile.weight)) kg")
                
                Divider()
                    .frame(height: 40)
                
                quickStatItem(label: "IMC", value: String(format: "%.1f", calculateBMI(profile: profile)))
                
                Divider()
                    .frame(height: 40)
                
                quickStatItem(label: "Calories", value: "\(Int(NutritionCalculator.shared.calculateNeeds(for: profile).totalCalories)) kcal")
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
        }
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    private func quickStatItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.accent)
        }
    }
    
    // Tab selector view
    private func profileTabView() -> some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20))
                        
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(selectedTab == tab ? AppTheme.accent : .gray)
                    .background(
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.4))
                                    .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // Matched geometry effect namespace
    @Namespace private var namespace
    
    // Extraction des sections d'informations
    private func profileInfoContent(profile: UserProfile) -> some View {
        VStack(spacing: 20) {
            // Informations personnelles
            ProfileCardView(title: "Informations personnelles", icon: "person.fill") {
                StatRowView(title: "Nom", value: profile.name, icon: "person.text.rectangle.fill")
                StatRowView(title: "Âge", value: "\(profile.age) ans", icon: "calendar")
                StatRowView(title: "Genre", value: profile.gender.rawValue, icon: "figure.wave")
            }
            
            // Mensurations
            ProfileCardView(title: "Mensurations", icon: "figure.arms.open") {
                StatRowView(title: "Taille", value: "\(Int(profile.height)) cm", icon: "ruler.fill")
                StatRowView(title: "Poids actuel", value: "\(Int(profile.weight)) kg", icon: "scalemass.fill")
                
                // Gestion différente selon si bodyFatPercentage est disponible
                if let bodyFatPercentage = profile.bodyFatPercentage {
                    StatRowView(title: "Masse graisseuse", value: "\(Int(bodyFatPercentage))%", icon: "drop.fill")
                    let leanMass = profile.weight * (1 - bodyFatPercentage / 100)
                    StatRowView(title: "Masse maigre", value: "\(Int(leanMass)) kg", icon: "figure.walk")
                } else {
                    StatRowView(title: "Masse graisseuse", value: "Non renseigné", icon: "drop.fill")
                    StatRowView(title: "Masse maigre", value: "Non renseigné", icon: "figure.walk")
                }
                
                StatRowView(title: "IMC", value: String(format: "%.1f", calculateBMI(profile: profile)), icon: "function")
            }
            
            // Mode de vie
            ProfileCardView(title: "Mode de vie", icon: "heart.fill") {
                StatRowView(title: "Objectif", value: profile.fitnessGoal.rawValue, icon: "target")
                StatRowView(title: "Niveau d'activité", value: profile.activityLevel.rawValue, icon: "figure.run")
                if !profile.dietaryRestrictions.isEmpty {
                    StatRowView(
                        title: "Préférences alimentaires",
                        value: profile.dietaryRestrictions.joined(separator: ", "),
                        icon: "leaf.fill"
                    )
                }
            }
            
            // Besoins nutritionnels
            ProfileCardView(title: "Besoins nutritionnels", icon: "fork.knife") {
                let needs = NutritionCalculator.shared.calculateNeeds(for: profile)
                
                StatRowView(
                    title: "Calories de maintenance",
                    value: "\(Int(needs.maintenanceCalories)) kcal",
                    icon: "flame.fill"
                )
                StatRowView(
                    title: "Calories recommandées",
                    value: "\(Int(needs.totalCalories)) kcal",
                    icon: "flame.fill"
                )
                StatRowView(
                    title: "Protéines",
                    value: "\(Int(needs.proteins))g",
                    icon: "staroflife.fill"
                )
                StatRowView(
                    title: "Glucides",
                    value: "\(Int(needs.carbs))g",
                    icon: "chart.pie.fill"
                )
                StatRowView(
                    title: "Lipides",
                    value: "\(Int(needs.fats))g",
                    icon: "drop.fill"
                )
            }
        }
        .padding()
    }
    
    // Contenu de l'onglet statistiques
    private func statsContent(profile: UserProfile) -> some View {
        let caloriesPerDay = getCaloriesPerDay(from: LocalDataManager.shared.fetchWeightsForLast7Days())
        let burnedCaloriesPerDay = caloriesPerDay.map { DailyCalorieStat(date: $0.date, value: 2200, type: "Brûlées")
        }
        

        return VStack(spacing: 20) {
            // Graphique de poids
            // MARK: - Carte Évolution du poids
            ProfileCardView(title: "Diagrammes", icon: "chart.line.uptrend.xyaxis") {
                ProfileStatsView(
                    weightData: localDataManager.fetchWeightsForLast7Days(),
                    foodEntries: LocalDataManager.shared.loadFoodEntries() ?? [],
                    userProfile: profile
                )

                .frame(height: 300)
                .padding(.horizontal, 8)
            }

            
            ProfileCardView(title: "Total sur les 7 derniers jours", icon: "chart.pie.fill") {
                VStack(spacing: 16) {
                    let needs = NutritionCalculator.shared.calculateNeeds(for: profile)

                    // Besoins hebdomadaires
                    let weeklyCaloriesNeed = needs.totalCalories * 7
                    let weeklyProteinNeed = needs.proteins * 7
                    let weeklyCarbsNeed = needs.carbs * 7
                    let weeklyFatsNeed = needs.fats * 7

                    // Derniers jours
                    let entries = LocalDataManager.shared.loadFoodEntries() ?? []
                    let last7Days = (0..<7).compactMap {
                        Calendar.current.date(byAdding: .day, value: -$0, to: Date())
                    }
                    let recentEntries = entries.filter { entry in
                        last7Days.contains { Calendar.current.isDate($0, inSameDayAs: entry.date) }
                    }

                    // Apports réels
                    let totalCalories = recentEntries.reduce(0.0) { $0 + $1.nutritionValues.calories }
                    let totalProteins = recentEntries.reduce(0.0) { $0 + $1.nutritionValues.proteins }
                    let totalCarbs    = recentEntries.reduce(0.0) { $0 + $1.nutritionValues.carbohydrates }
                    let totalFats     = recentEntries.reduce(0.0) { $0 + $1.nutritionValues.fats }

                    // Pourcentages
                    let proteinPercent = weeklyCaloriesNeed > 0 ? (totalProteins * 4 / weeklyCaloriesNeed) * 100 : 0
                    let carbsPercent   = weeklyCaloriesNeed > 0 ? (totalCarbs * 4 / weeklyCaloriesNeed) * 100 : 0
                    let fatsPercent    = weeklyCaloriesNeed > 0 ? (totalFats * 9 / weeklyCaloriesNeed) * 100 : 0

                    // Cercle des macros
                    HStack(spacing: 20) {
                        MacroCircleView(
                            percent: proteinPercent,
                            color: .purple,
                            title: "Protéines",
                            value: "\(Int(totalProteins))g / \(Int(weeklyProteinNeed))g"
                        )
                        MacroCircleView(
                            percent: carbsPercent,
                            color: .orange,
                            title: "Glucides",
                            value: "\(Int(totalCarbs))g / \(Int(weeklyCarbsNeed))g"
                        )
                        MacroCircleView(
                            percent: fatsPercent,
                            color: .blue,
                            title: "Lipides",
                            value: "\(Int(totalFats))g / \(Int(weeklyFatsNeed))g"
                        )
                    }

                    Text(" \(Int(totalCalories)) kcal sur \(Int(weeklyCaloriesNeed)) kcal")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                }
                .padding(.vertical, 8)
            }


            
            // Progrès vers l'objectif
            ProfileCardView(title: "Progression", icon: "target") {
                VStack(alignment: .leading, spacing: 12) {
                    Text(getGoalDescription(profile: profile))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ProgressBar(
                        value: calculateProgressToGoal(profile: profile),
                        color: AppTheme.accent
                    )

                    HStack {
                        Text("Poids de départ").font(.caption).foregroundColor(.secondary)
                        Spacer()
                        Text("Objectif").font(.caption).foregroundColor(.secondary)
                    }

                    HStack {
                        Text("\(Int(profile.startingWeight)) kg")
                            .font(.subheadline)
                            .fontWeight(.bold)

                        Spacer()

                        TextField("Objectif", value: Binding(
                            get: { profile.targetWeight ?? profile.weight },
                            set: { newTarget in
                                localDataManager.updateTargetWeight(to: newTarget)
                            }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                    }

                    Button {
                        showAddWeightSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Ajouter mon poids aujourd’hui")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                    }

                    HStack {
                        Spacer()
                        Button {
                            showWeightList = true
                        } label: {
                            Label("Historique", systemImage: "list.bullet.rectangle.portrait")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.gray.opacity(0.15))
                    }
                }
                .sheet(isPresented: $showAddWeightSheet) {
                    AddWeightTodayView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        .presentationDetents([.fraction(0.3)])
                }

                .sheet(isPresented: $showWeightList) {
                    WeightListView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                }
            }

            .sheet(isPresented: $showWeightListView) {
                WeightListView()
            }


        }
        .padding()
    }
    
    // Contenu de l'onglet paramètres
    private func settingsContent() -> some View {
        VStack(spacing: 20) {
            // Intégrations
            ProfileCardView(title: "Intégrations", icon: "link") {
                SettingsToggleRow(
                    title: "Apple Santé",
                    icon: "heart.circle.fill",
                    iconColor: .red,
                    isEnabled: .constant(false),
                    action: {
                        showHealthKitPermissions = true
                    }
                )
                
                Button(action: {
                    showHealthKitPermissions = true
                }) {
                    HStack {
                        Text("Configurer Apple Santé")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Notifications
            ProfileCardView(title: "Notifications", icon: "bell.fill") {
                SettingsToggleRow(
                    title: "Rappels de repas",
                    icon: "fork.knife",
                    iconColor: .orange,
                    isEnabled: .constant(true)
                )
                
                SettingsToggleRow(
                    title: "Rappels d'eau",
                    icon: "drop.fill",
                    iconColor: .blue,
                    isEnabled: .constant(true)
                )
                
                SettingsToggleRow(
                    title: "Mise à jour hebdomadaire",
                    icon: "calendar",
                    iconColor: .purple,
                    isEnabled: .constant(true)
                )
            }
            
            // Préférences de l'application
            ProfileCardView(title: "Préférences", icon: "gearshape.fill") {
                VStack(spacing: 0) {
                    SettingsLinkRow(
                        title: "Unités de mesure",
                        icon: "ruler",
                        iconColor: .gray,
                        value: "Métrique"
                    )
                    
                    SettingsLinkRow(
                        title: "Thème",
                        icon: "paintpalette.fill",
                        iconColor: .purple,
                        value: "Clair"
                    )
                    
                    SettingsLinkRow(
                        title: "Langue",
                        icon: "globe",
                        iconColor: .blue,
                        value: "Français"
                    )
                }
            }
            
            // Version de l'application
            ProfileCardView(title: "À propos", icon: "info.circle.fill") {
                VStack(alignment: .center, spacing: 8) {
                    Image("Icon-scan")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text("NutrIA")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Action rate app
                    }) {
                        Text("Noter l'application")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.accent)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding()
    }
    
    // Helpers
    private func calculateBMI(profile: UserProfile) -> Double {
        let heightInMeters = profile.height / 100
        return profile.weight / (heightInMeters * heightInMeters)
    }
    
    private func getCaloriesPerDay(from entries: [WeightEntry]) -> [DailyCalorieStat] {
        let allEntries = LocalDataManager.shared.loadFoodEntries() ?? []

        let grouped = Dictionary(grouping: allEntries) { Calendar.current.startOfDay(for: $0.date) }

        return entries.map { weightEntry in
            let day = Calendar.current.startOfDay(for: weightEntry.date)
            let total = grouped[day]?.reduce(0) { $0 + $1.nutritionValues.calories } ?? 0
            return DailyCalorieStat(date: day, value: total, type: "Consommées")
        }
    }

    
    private func minWeight(profile: UserProfile) -> Double {
        min(profile.weight, profile.targetWeight ?? profile.weight) - 1
    }

    private func maxWeight(profile: UserProfile) -> Double {
        max(profile.startingWeight, profile.weight, profile.targetWeight ?? profile.weight) + 1
    }

    
    private func maxCaloriesYScale() -> Int {
        let all = getCaloriesPerDay(from: LocalDataManager.shared.fetchWeightsForLast7Days()).map { localDataManager.getCaloriesConsumed(on: $0.date) } + [2200]
        return (all.max() ?? 2500) + 300
    }
    
    private func calculateProgressToGoal(profile: UserProfile) -> Double {
        guard let targetWeight = profile.targetWeight else { return 0.0 }
        
        let isWeightLoss = profile.startingWeight > targetWeight
        let totalChange = abs(profile.startingWeight - targetWeight)
        let currentChange = isWeightLoss
            ? profile.startingWeight - profile.weight
            : profile.weight - profile.startingWeight
        
        // Limiter entre 0 et 1
        let progress = min(max(currentChange / totalChange, 0), 1)
        return progress
    }
    
    private func getGoalDescription(profile: UserProfile) -> String {
        guard let targetWeight = profile.targetWeight else {
            return "Objectif non défini"
        }
        
        if profile.startingWeight > targetWeight {
            return "Perte de poids: \(Int(profile.startingWeight - targetWeight)) kg"
        } else if profile.startingWeight < targetWeight {
            return "Prise de poids: \(Int(targetWeight - profile.startingWeight)) kg"
        } else {
            return "Maintien du poids actuel"
        }
    }
    
    private func weightChange(_ data: [WeightEntry]) -> Double {
        guard let first = data.first, let last = data.last else { return 0 }
        return last.weight - first.weight
    }
    
    private func weightChangeFormatted(_ data: [WeightEntry]) -> String {
        let change = weightChange(data)
        return String(format: "%.1f", change)
    }
}

struct DailyCalorieStat: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    var type: String
}


// Modèles et composants auxiliaires
enum ProfileTab: CaseIterable {
    case info, stats, settings
    
    var title: String {
        switch self {
        case .info: return "Profil"
        case .stats: return "Statistiques"
        case .settings: return "Paramètres"
        }
    }
    
    var iconName: String {
        switch self {
        case .info: return "person.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// Composants de l'interface

struct ProfileCardView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(AppTheme.accent)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            // Content
            content
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct StatRowView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundColor(AppTheme.accent)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
    }
}

struct MacroCircleView: View {
    let percent: Double
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            ZStack {
                // Background
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // Progress
                Circle()
                    .trim(from: 0, to: CGFloat(min(percent / 100, 1.0)))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                // Label
                VStack(spacing: 0) {
                    Text("\(Int(percent))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                }
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
struct MacroCircleHomeView: View {
    let percent: Double
    let color: Color
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Cercle d'arrière-plan
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 5.5)
                    .frame(width: 50, height: 50)

                // Cercle de progression
                Circle()
                    .trim(from: 0, to: CGFloat(min(percent / 100, 1.0)))
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 5.5, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: -90)) // <- correction ici

                // Pourcentage au centre
                Text("\(Int(percent))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }

            // Titre
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            // Valeur
            Text(value)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}



struct SettingsToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isEnabled: Bool
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 28)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
    }
}

struct SettingsLinkRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    let value: String
    
    var body: some View {
        Button(action: {
            // Action
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 28)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
    }
}

// Vue pour la configuration Apple Santé
struct HealthKitPermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding(.top, 40)
                
                Text("Connexion avec Apple Santé")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Autorisez NutrIA à accéder à vos données dans Apple Santé pour synchroniser vos informations de poids, activité et nutrition.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    PermissionRow(icon: "scalemass.fill", title: "Poids", description: "Pour suivre votre progression")
                    PermissionRow(icon: "figure.walk", title: "Activité", description: "Pour calculer les calories dépensées")
                    PermissionRow(icon: "fork.knife", title: "Nutrition", description: "Pour synchroniser votre alimentation")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    isProcessing = true
                    // Simuler le traitement
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isProcessing = false
                        dismiss()
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 10)
                        }
                        
                        Text("Autoriser l'accès")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.actionButtonProgressGradient)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .disabled(isProcessing)
                
                Button("Pas maintenant") {
                    dismiss()
                }
                .padding()
                .foregroundColor(.secondary)
            }
            .navigationTitle("Apple Santé")
            .navigationBarItems(trailing: Button("Fermer") {
                dismiss()
            })
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.accent)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// Extensions et thèmes

extension AppTheme {
    static let actionButtonProgressGradient = LinearGradient(
        gradient: Gradient(colors: [accent, accent.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let progressGradient = LinearGradient(
        gradient: Gradient(colors: [.green, accent]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
