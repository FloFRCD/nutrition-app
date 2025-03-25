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
    
    // Ajoutez un publisher pour notifier les changements
    @Published var foodEntries: [FoodEntry] = []

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
        
        // Ajoutez cette entrée alimentaire à votre journal
        addFoodEntry(foodEntry)
        
        // Assurez-vous que les données sont aussi sauvegardées dans le LocalDataManager
        // pour que JournalViewModel puisse les voir
        LocalDataManager.shared.saveFoodEntries(foodEntries)
        
        // Ajouter des logs pour voir les valeurs réelles
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
        foodEntries.append(foodEntry)
        // Notifier le JournalViewModel ou sauvegarder dans une source commune
        LocalDataManager.shared.saveFoodEntries(foodEntries)
        
        // Notifier les observateurs
        objectWillChange.send()
    }
    
    
    func debugCIQUALDatabase() {
        loadCIQUALDatabase() // Charge les données
        
        if !ciqualFoods.isEmpty {
            print("✅ CIQUAL: Premier aliment chargé: \(ciqualFoods[0].nom)")
            print("- Calories: \(ciqualFoods[0].energie_kcal ?? 0) kcal")
            print("- Protéines: \(ciqualFoods[0].proteines ?? 0) g")
            print("- Glucides: \(ciqualFoods[0].glucides ?? 0) g")
            print("- Lipides: \(ciqualFoods[0].lipides ?? 0) g")
            
            print("🔍 CIQUAL: Exemple de recherche 'chocolat': \(searchCIQUALFoods(query: "chocolat").count) résultats")
        } else {
            print("❌ CIQUAL: Aucun aliment n'a été chargé")
        }
    }
    
    func loadSomeData() {
        // Si c'est une opération asynchrone
        DispatchQueue.global().async {
            // Exemple: charger des données en arrière-plan
            // Par exemple, si vous chargez des foodEntries depuis une source externe
            let loadedEntries = self.performBackgroundLoading() // Votre méthode de chargement
            
            // Puis mise à jour de l'UI sur le thread principal
            DispatchQueue.main.async {
                self.foodEntries = loadedEntries // Utiliser votre propre propriété publiée
                // Vous pourriez aussi faire:
                // self.objectWillChange.send() // Si nécessaire pour notifier les changements
            }
        }
    }

    // Méthode d'exemple pour simuler un chargement en arrière-plan
    private func performBackgroundLoading() -> [FoodEntry] {
        // Votre logique de chargement
        return []
    }
    // Ajoutez une fonction pour lire les premières lignes du JSON sans le décoder
    func debugRawJSON() {
        guard let url = Bundle.main.url(forResource: "ciqual_data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Fichier JSON introuvable")
            return
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstItem = jsonObject.first {
                print("📝 Structure du premier élément:")
                firstItem.forEach { key, value in
                    print("   \(key): \(type(of: value)) = \(value)")
                }
            }
        } catch {
            print("❌ Erreur lors de l'analyse JSON: \(error)")
        }
    }
    
    func checkBundleForJSONFiles() {
        let extensions = ["json", "JSON"]
        
        print("🔍 Recherche de fichiers JSON dans le bundle:")
        
        // Chercher tous les fichiers .json et .JSON
        for ext in extensions {
            if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) {
                urls.forEach { url in
                    print("   - \(url.lastPathComponent)")
                }
            }
        }
        
        // Vérifier spécifiquement le fichier ciqual_data.json
        if Bundle.main.url(forResource: "ciqual_data", withExtension: "json") != nil {
            print("✅ ciqual_data.json trouvé dans le bundle")
        } else {
            print("❌ ciqual_data.json NON trouvé dans le bundle")
        }
    }
}
