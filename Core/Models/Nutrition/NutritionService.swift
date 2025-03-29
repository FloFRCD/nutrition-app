//
//  NutritionService.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 26/02/2025.
//

import Foundation
import Combine


class NutritionService: ObservableObject {
    static let shared = NutritionService()
    private let openFoodFactsService = OpenFoodFactsService()
    private var ciqualFoods: [CIQUALFood] = []
    private var isCiqualLoaded = false
    private weak var journalViewModel: JournalViewModel?
    @Published var foodEntries: [FoodEntry] = []
    @Published var customFoods: [CustomFood] = []
    
    // MARK: - Recipe Analysis Methods
    
    /// Vérifie si une recette respecte les objectifs nutritionnels d'un profil utilisateur
    func isRecipeMatchingUserGoals(_ recipe: Recipe, userProfile: UserProfile) -> Bool {
        guard let nutrition = recipe.nutritionValues else {
            return false
        }
        
        let userNeeds = NutritionCalculator.shared.calculateNeeds(for: userProfile)
        
        // Vérifier si la recette correspond aux besoins (approximativement)
        switch userProfile.fitnessGoal {
        case .loseWeight:
            // Pour la perte de poids, vérifier que les calories sont modérées
            // et les protéines suffisantes
            return nutrition.calories < userNeeds.totalCalories / 3 &&
            nutrition.proteins > userNeeds.proteins / 4
            
        case .maintainWeight:
            // Pour le maintien, vérifier un équilibre général
            return nutrition.calories < userNeeds.maintenanceCalories / 3 &&
            nutrition.calories > userNeeds.maintenanceCalories / 5
            
        case .gainMuscle:
            // Pour le gain musculaire, vérifier que les protéines sont élevées
            return nutrition.proteins > userNeeds.proteins / 3
        }
    }
    
    // MARK: - Nutrition Information Methods
    
    /// Analyse complète d'une recette en recherchant les informations nutritionnelles pour chaque ingrédient
    func analyzeRecipeNutrition(_ recipe: Recipe) async throws -> Recipe {
        var updatedRecipe = recipe
        
        // Calculer les valeurs nutritionnelles totales
        var totalCalories: Double = 0
        var totalProteins: Double = 0
        var totalCarbs: Double = 0
        var totalFats: Double = 0
        var totalFiber: Double = 0
        
        // Pour chaque ingrédient
        for ingredient in recipe.ingredients {
            if let gramsAmount = ingredient.quantityInGrams() {
                // Utiliser AIService pour obtenir les infos nutritionnelles
                let nutritionInfo = try await AIService.shared.analyzeNutrition(food: "\(gramsAmount)g de \(ingredient.name)")
                
                // Ajouter aux totaux
                totalCalories += nutritionInfo.calories
                totalProteins += nutritionInfo.proteins
                totalCarbs += nutritionInfo.carbs
                totalFats += nutritionInfo.fats
                
                // Gestion de la fiber - avec vérification de sa présence
                if nutritionInfo.fiber > 0 {
                    totalFiber += nutritionInfo.fiber
                } else {
                    // Si fiber est 0 ou inexistant, utiliser estimation
                    totalFiber += nutritionInfo.carbs * 0.1
                }
            }
        }
        
        // Calculer par portion
        let caloriesPerServing = totalCalories / Double(recipe.servings)
        let proteinsPerServing = totalProteins / Double(recipe.servings)
        let carbsPerServing = totalCarbs / Double(recipe.servings)
        let fatsPerServing = totalFats / Double(recipe.servings)
        let fiberPerServing = totalFiber / Double(recipe.servings)
        
        // Créer l'objet NutritionValues avec une valeur par défaut pour fiber si nécessaire
        let nutritionValues = NutritionValues(
            calories: caloriesPerServing,
            proteins: proteinsPerServing,
            carbohydrates: carbsPerServing,
            fats: fatsPerServing,
            fiber: fiberPerServing > 0 ? fiberPerServing : carbsPerServing * 0.1
        )
        
        // Mettre à jour la recette
        updatedRecipe.nutritionValues = nutritionValues
        
        return updatedRecipe
    }
    
    // MARK: - Future OpenFoodFacts Integration
    
    /// Cette méthode sera implémentée ultérieurement avec OpenFoodFacts
    func findIngredientInOpenFoodFacts(_ ingredientName: String) async throws -> String? {
        // Dans une future implémentation, cela recherchera l'ingrédient dans OpenFoodFacts
        // et retournera son ID
        return nil
    }
    
    func addCIQUALFoodToJournal(ciqualFoodId: String, quantity: Double, mealType: MealType) {
        guard let ciqualFood = getCIQUALFood(byId: ciqualFoodId) else {
            return
        }
        
        let foodEntry = createFoodEntryFromCIQUAL(
            ciqualFood: ciqualFood,
            quantity: quantity,
            mealType: mealType
        )
        
        // Utiliser la méthode addFoodEntry mise à jour
        addFoodEntry(foodEntry)
        
        // Logs
        print("DEBUG: Ajout aliment \(ciqualFood.nom) avec \(quantity)g")
        print("DEBUG: Valeurs nutritionnelles: Cal: \(ciqualFood.energie_kcal ?? 0), Prot: \(ciqualFood.proteines ?? 0), Gluc: \(ciqualFood.glucides ?? 0), Lip: \(ciqualFood.lipides ?? 0)")
    }
    
    // 1. Fonction pour charger la base CIQUAL
    func loadCIQUALDatabase() {
        if isCiqualLoaded { return }
        
        // Liste des noms possibles à essayer
        let possibleNames = ["ciqual_data", "ciqual-data", "ciqual"]
        let possibleExtensions = ["json", "JSON"]
        
        var fileLoaded = false
        
        // Essayer toutes les combinaisons
        for name in possibleNames {
            for ext in possibleExtensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    print("✅ Fichier CIQUAL trouvé: \(name).\(ext)")
                    do {
                        let data = try Data(contentsOf: url)
                        // Essayez de décoder
                        ciqualFoods = try JSONDecoder().decode([CIQUALFood].self, from: data)
                        isCiqualLoaded = true
                        fileLoaded = true
                        print("✅ Chargement réussi: \(ciqualFoods.count) aliments")
                        return
                    } catch {
                        print("❌ Erreur lors du décodage de \(name).\(ext): \(error)")
                    }
                }
            }
        }
        
        if !fileLoaded {
            // Lister tous les fichiers dans le bundle pour déboguer
            let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) ?? []
            print("📁 Fichiers dans le bundle:")
            urls.forEach { print("   - \($0.lastPathComponent)") }
        }
    }
    
    func searchCIQUALFoods(query: String) -> [CIQUALFood] {
        if query.isEmpty { return [] }
        
        loadCIQUALDatabase()
        
        return ciqualFoods.filter {
            // Filtrer par nom ET s'assurer que l'aliment a des calories > 0
            $0.nom.lowercased().contains(query.lowercased()) &&
            ($0.energie_kcal ?? 0) > 0
        }
    }
    
    func getCIQUALFood(byId id: String) -> CIQUALFood? {
        loadCIQUALDatabase()
        return ciqualFoods.first(where: { $0.id == id })
    }
    
    func createFoodEntryFromCIQUAL(ciqualFood: CIQUALFood, quantity: Double, mealType: MealType) -> FoodEntry {
        // Créer un objet Food à partir de CIQUALFood
        let food = Food(
            id: UUID(),
            name: ciqualFood.nom,
            calories: Int(ciqualFood.energie_kcal ?? 0),
            proteins: ciqualFood.proteines ?? 0,
            carbs: ciqualFood.glucides ?? 0,
            fats: ciqualFood.lipides ?? 0,
            fiber: ciqualFood.fibres ?? 0,  // Vérifiez que cette ligne existe
            servingSize: 100,
            servingUnit: .gram,
            image: nil
        )
        // Créer et retourner une FoodEntry
        return FoodEntry(
            id: UUID(),
            food: food,
            quantity: quantity,
            date: Date(),
            mealType: mealType,
            source: .manual  // ou créer un nouveau type pour CIQUAL
        )
    }
    
    func addFoodEntry(_ foodEntry: FoodEntry) {
        // Charger les entrées existantes depuis LocalDataManager
        if var existingEntries = LocalDataManager.shared.loadFoodEntries() {
            // Ajouter la nouvelle entrée
            existingEntries.append(foodEntry)
            // Sauvegarder
            LocalDataManager.shared.saveFoodEntries(existingEntries)
        } else {
            // Aucune entrée existante
            LocalDataManager.shared.saveFoodEntries([foodEntry])
        }
        
        // Notifier les observateurs
        objectWillChange.send()
    }
    func setJournalViewModel(_ viewModel: JournalViewModel) {
        DispatchQueue.main.async {
            // Capture faible pour éviter les cycles de rétention
            self.journalViewModel = viewModel
            
            // Synchroniser les entrées existantes si nécessaire
            if !self.foodEntries.isEmpty {
                viewModel.foodEntries = self.foodEntries
            }
        }
    }
}

extension NutritionService {
    
    // Charger les aliments personnalisés
    func loadCustomFoods() {
        customFoods = LocalDataManager.shared.loadCustomFoods()
        objectWillChange.send()
    }
    
    // Sauvegarder un aliment personnalisé depuis un Food
    func saveCustomFood(_ food: Food) {
        let customFood = CustomFood(from: food)
        LocalDataManager.shared.addCustomFood(customFood)
        
        // Mettre à jour la liste en mémoire
        if !customFoods.contains(where: { $0.id == customFood.id }) {
            customFoods.append(customFood)
            objectWillChange.send()
        }
        
        print("✅ Aliment personnalisé sauvegardé: \(food.name)")
    }
    
    // Supprimer un aliment personnalisé
    func removeCustomFood(id: UUID) {
        LocalDataManager.shared.removeCustomFood(id: id)
        
        // Mettre à jour la liste en mémoire
        customFoods.removeAll { $0.id == id }
        objectWillChange.send()
    }
    
    // Rechercher des aliments personnalisés
    func searchCustomFoods(query: String) -> [CustomFood] {
        if query.isEmpty {
            return customFoods
        }
        
        return customFoods.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
    }
    
    // Ajouter un aliment personnalisé au journal
    func addCustomFoodToJournal(customFood: CustomFood, quantity: Double, mealType: MealType, date: Date) {
        let food = customFood.toFood()
        
        let entry = FoodEntry(
            id: UUID(),
            food: food,
            quantity: quantity / food.servingSize,  // Ajuster la quantité en fonction de la taille de portion
            date: date,
            mealType: mealType,
            source: .favorite // Utiliser favorite comme source pour les aliments personnalisés
        )
        
        addFoodEntry(entry)
    }
}
