//
//  JournalViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import SwiftUI
import Combine


class JournalViewModel: ObservableObject {
    // Published properties
    @Published var foodEntries: [FoodEntry] = []
    @Published var _activeSheet: JournalSheet?
    @Published var selectedDate: Date = Date()
    @Published var burnedCaloriesPerDay: [Date: Double] = [:]
    
    // Services
    private let nutritionCalculator = NutritionCalculator.shared
    private let nutritionService = NutritionService.shared
    private let localDataManager = LocalDataManager.shared
    private weak var journalViewModel: JournalViewModel?
    
    // MARK: - Initialization
    
    init() {
        
        Task {
            await loadFoodEntries()
            await loadBurnedCalories()
            }
        NutritionService.shared.setJournalViewModel(self)
    }
    
    
    var activeSheet: JournalSheet? {
        get {
            return _activeSheet
        }
        set {
            _activeSheet = newValue
            if newValue == nil {
                // Recharger les entrées quand une sheet est fermée
                reloadFoodEntries()
            }
        }
    }
    
    // Computed properties
    var userProfile: UserProfile {
        return localDataManager.userProfile ?? UserProfile.default
    }
    
    var dailyCalorieGoal: Double {
        // Utiliser le nouveau NutritionCalculator centralisé
        return nutritionCalculator.calculateNeeds(for: userProfile).totalCalories
    }
    
    // MARK: - Data filtering
    
    func entriesForDate(_ date: Date) -> [FoodEntry] {
        return foodEntries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func entriesForMealType(mealType: MealType, date: Date) -> [FoodEntry] {
        return entriesForDate(date).filter { entry in
            entry.mealType == mealType
        }
    }
    
    func totalNutritionForDate(_ date: Date) -> NutritionValues {
        let entries = entriesForDate(date)
        
        return entries.reduce(NutritionValues(calories: 0, proteins: 0, carbohydrates: 0, fats: 0, fiber: 0)) { result, entry in
            return NutritionValues(
                calories: result.calories + entry.nutritionValues.calories,
                proteins: result.proteins + entry.nutritionValues.proteins,
                carbohydrates: result.carbohydrates + entry.nutritionValues.carbohydrates,
                fats: result.fats + entry.nutritionValues.fats,
                fiber: result.fiber + entry.nutritionValues.fiber
            )
        }
    }
    
    // MARK: - Target calories
    
    func targetCaloriesFor(mealType: MealType) -> Int {
        // Utiliser le nouveau NutritionCalculator pour obtenir les répartitions par repas
        let needs = nutritionCalculator.calculateNeeds(for: userProfile)
        
        switch mealType {
        case .breakfast: return Int(needs.breakfastCalories)
        case .lunch: return Int(needs.lunchCalories)
        case .dinner: return Int(needs.dinnerCalories)
        case .snack: return Int(needs.snackCalories)
        }
    }
    
    // MARK: - Nutrition goals
    
    func nutritionGoals() -> NutritionValues {
        let needs = nutritionCalculator.calculateNeeds(for: userProfile)
        
        return NutritionValues(
            calories: needs.totalCalories,
            proteins: needs.proteins,
            carbohydrates: needs.carbs,
            fats: needs.fats,
            fiber: needs.fiber
        )
    }
    
    // MARK: - Sheet presentation
    
    func showFoodPhotoCapture(for mealType: MealType) {
        activeSheet = .photoCapture(mealType: mealType)
    }
    
    func showRecipeSelection(for mealType: MealType) {
        activeSheet = .recipeSelection(mealType: mealType)
    }
    
    func showIngredientEntry(for mealType: MealType) {
        activeSheet = .ingredientEntry(mealType: mealType)
    }
    
    // MARK: - Food entry management
    
    func addFoodEntry(_ entry: FoodEntry) {
        // Charger les entrées existantes
        var existingEntries = LocalDataManager.shared.loadFoodEntries() ?? []
        
        // Vérifier si une entrée similaire existe déjà (même nom, même date et même repas)
        let entryExists = existingEntries.contains { existingEntry in
            return existingEntry.food.name == entry.food.name &&
                   Calendar.current.isDate(existingEntry.date, inSameDayAs: entry.date) &&
                   existingEntry.mealType == entry.mealType
        }
        
        // N'ajouter que si elle n'existe pas déjà
        if !entryExists {
            existingEntries.append(entry)
            LocalDataManager.shared.saveFoodEntries(existingEntries)
            
            // Si vous utilisez une propriété published
            self.foodEntries = existingEntries
            objectWillChange.send()
            
            print("✅ Nouvelle entrée ajoutée : \(entry.food.name) pour \(entry.mealType.rawValue)")
        } else {
            print("⚠️ Entrée déjà existante, non ajoutée : \(entry.food.name) pour \(entry.mealType.rawValue)")
        }
    }
    
    func removeFoodEntry(_ entry: FoodEntry) {
        if let index = foodEntries.firstIndex(where: { $0.id == entry.id }) {
            print("foodEntries.remove(at: index)")
            foodEntries.remove(at: index)
            
            // Utiliser Task pour s'assurer que la sauvegarde est terminée avant de continuer
            Task {
                // Sauvegarder immédiatement
                self.localDataManager.saveFoodEntries(self.foodEntries)  // Ajout de 'self.'
                
                // Attendre un court moment pour s'assurer que la sauvegarde est terminée
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 secondes
                
                // Forcer une synchronisation et une vérification
                DispatchQueue.main.async {
                    // Vérifier si la suppression a bien été prise en compte
                    if let savedEntries = self.localDataManager.loadFoodEntries(),  // Ajout de 'self.'
                       savedEntries.contains(where: { $0.id == entry.id }) {
                        // L'entrée existe encore, forcer une nouvelle sauvegarde
                        print("⚠️ L'entrée supprimée existe encore, forcer une nouvelle sauvegarde")
                        var correctedEntries = savedEntries
                        correctedEntries.removeAll { $0.id == entry.id }
                        self.localDataManager.saveFoodEntries(correctedEntries)  // Ajout de 'self.'
                        self.foodEntries = correctedEntries
                    }
                }
            }
        }
    }
    func reloadFoodEntries() {
        foodEntries = localDataManager.loadFoodEntries() ?? []
    }
    
    // MARK: - Processing methods
    
    func processAndAddFoodPhoto(_ image: UIImage, mealType: MealType, date: Date) async {
        // Remplacer par l'appel réel à l'API de reconnaissance alimentaire
        // Pour l'instant, utilisons un placeholder
        
        do {
            // Simuler un temps de traitement
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let food = Food(
                id: UUID(),
                name: "Aliment détecté",
                calories: 250,
                proteins: 12,
                carbs: 30,
                fats: 8,
                fiber: 2,
                servingSize: 100,
                servingUnit: .gram,
                image: nil
            )
            
            let entry = FoodEntry(
                id: UUID(),  // Explicitement fournir l'ID, même s'il y a une valeur par défaut
                food: food,
                quantity: 1,
                date: date,
                mealType: mealType,
                source: .recipe  // Assurez-vous que FoodSource.recipe est le cas correct
            )
            
            DispatchQueue.main.async {
                self.addFoodEntry(entry)
                self.activeSheet = nil
            }
        } catch {
            print("Erreur lors de l'analyse de l'image: \(error)")
        }
    }
    
    func addRecipeToJournal(_ recipe: Recipe, mealType: MealType, date: Date) {
        guard let nutritionValues = recipe.nutritionValues else { return }
        
        let food = Food(
            id: UUID(),
            name: recipe.name,
            calories: Int(nutritionValues.calories),
            proteins: nutritionValues.proteins,
            carbs: nutritionValues.carbohydrates,
            fats: nutritionValues.fats,
            fiber: nutritionValues.fiber,
            servingSize: 1,
            servingUnit: .piece,
            image: nil
        )
        
        let entry = FoodEntry(
            food: food,
            quantity: 1,
            date: date,
            mealType: mealType,
            source: .recipe
        )
        
        addFoodEntry(entry)
        activeSheet = nil
    }
    
    func processAndAddIngredients(_ ingredients: [String: Double], mealType: MealType, date: Date) async {
        do {
            // Formater les ingrédients pour l'API
            let ingredientsText = ingredients.map { "\($0.value)g de \($0.key)" }.joined(separator: ", ")
            
            // Obtenir les infos nutritionnelles via l'API
            let nutritionInfo = try await AIService.shared.analyzeNutrition(food: ingredientsText)
            
            // Créer un aliment à partir des infos obtenues
            let food = Food(
                id: UUID(),
                name: "Repas personnalisé",
                calories: Int(nutritionInfo.calories),
                proteins: nutritionInfo.proteins,
                carbs: nutritionInfo.carbs,
                fats: nutritionInfo.fats,
                fiber: nutritionInfo.fiber,
                servingSize: 1,
                servingUnit: .piece,
                image: nil
            )
            
            let entry = FoodEntry(
                food: food,
                quantity: 1,
                date: date,
                mealType: mealType,
                source: .manual
            )
            
            DispatchQueue.main.async {
                self.addFoodEntry(entry)
                self.activeSheet = nil
            }
        } catch {
            print("Erreur lors de l'analyse des ingrédients: \(error)")
        }
    }
    
    func addDetailedRecipeToJournal(_ recipe: DetailedRecipe, servings: Double, mealType: MealType) {
        // Créer un Food à partir de la recette détaillée
        let food = Food(
            id: UUID(),
            name: recipe.name,
            calories: recipe.nutritionFacts.calories,
            proteins: recipe.nutritionFacts.proteins,
            carbs: recipe.nutritionFacts.carbs,
            fats: recipe.nutritionFacts.fats,
            fiber: recipe.nutritionFacts.fiber,
            servingSize: 1, // Une portion
            servingUnit: .piece,
            image: nil
        )
        
        // Utiliser la date actuelle ou selectedDate de votre ViewModel
        let entry = FoodEntry(
            id: UUID(),
            food: food,
            quantity: servings, // Utilisez servings ici au lieu de 1 fixe
            date: selectedDate, // Utilisez selectedDate qui est une propriété du ViewModel
            mealType: mealType,
            source: .recipe
        )
        
        addFoodEntry(entry)
        activeSheet = nil
    }
    
    // MARK: - Date navigation
    
    func goToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = nextDay
        }
    }
    
    func goToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = previousDay
        }
    }
    
    // MARK: - Persistence
    
    func loadFoodEntries() {
        let entries = localDataManager.loadFoodEntries() ?? []
        Task { @MainActor in
            self.foodEntries = entries
        }
    }

    
    func saveFoodEntries() {
        localDataManager.saveFoodEntries(foodEntries)
    }
    func showCustomFoodEntry(for mealType: MealType) {
        activeSheet = .customFoodEntry(mealType: mealType)
    }
    func showMyFoodsSelector(for mealType: MealType) {
            activeSheet = .myFoodsSelector(mealType: mealType)
        }
    func showBarcodeScanner(for mealType: MealType) {
        activeSheet = .barcodeScanner(mealType: mealType)
    }
    
    func setBurnedCalories(_ calories: Double, for date: Date) {
        let cleanDate = Calendar.current.startOfDay(for: date)
        burnedCaloriesPerDay[cleanDate] = calories
        Task {
            await saveBurnedCalories()
        }
    }
    
    func showBurnedCaloriesEntry() {
        activeSheet = .burnedCaloriesEntry
    }


    func getBurnedCalories(for date: Date) -> Double {
        let cleanDate = Calendar.current.startOfDay(for: date)
        return burnedCaloriesPerDay[cleanDate] ?? 0
    }
    
    func caloriesConsumed(on date: Date) -> Double {
        let entriesForDate = foodEntries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        return entriesForDate.reduce(0) { $0 + $1.nutritionValues.calories }
    }


    // Sauvegarde/chargement (via LocalDataManager)
    func saveBurnedCalories() async {
        try? await localDataManager.save(burnedCaloriesPerDay, forKey: "burnedCaloriesPerDay")
    }

    func loadBurnedCalories() async {
        let loaded: [Date: Double] = (try? await localDataManager.load(forKey: "burnedCaloriesPerDay")) ?? [:]
        await MainActor.run {
            burnedCaloriesPerDay = loaded
        }
    }
}

extension JournalViewModel {
    func processAndAddFoodPhoto(_ image: UIImage, mealType: MealType, userComment: String) async {
        do {
            // Analyse de l'image avec GPT-4 Vision
            let (foodName, nutritionInfo) = try await AIService.shared.analyzeFoodPhoto(image, userComment: userComment)
            
            // Créer un Food à partir des informations
            let food = Food(
                id: UUID(),
                name: foodName,
                calories: Int(nutritionInfo.calories),
                proteins: nutritionInfo.proteins,
                carbs: nutritionInfo.carbs,
                fats: nutritionInfo.fats,
                fiber: nutritionInfo.fiber,
                servingSize: 1,
                servingUnit: .piece,
                image: nil
            )
            
            // Créer une entrée pour le journal
            let entry = FoodEntry(
                id: UUID(),
                food: food,
                quantity: 1,
                date: selectedDate,
                mealType: mealType,
                source: .foodPhoto
            )
            
            // Enregistrer le scan dans l'historique
            let foodScan = FoodScan(
                foodName: foodName,
                nutritionInfo: nutritionInfo,
                date: Date(),
                mealType: mealType
            )
            LocalDataManager.shared.saveFoodScan(foodScan)
            
            // Ajouter l'entrée au journal
            DispatchQueue.main.async {
                self.addFoodEntry(entry)
                self.activeSheet = nil
            }
        } catch {
            print("Erreur lors de l'analyse de l'image: \(error)")
            
            // Gestion de l'erreur - vous pouvez ajouter ici un code pour afficher une alerte
            DispatchQueue.main.async {
                self.activeSheet = nil
                // Vous pourriez déclencher une alerte ou un message d'erreur ici
            }
        }
    }
}
