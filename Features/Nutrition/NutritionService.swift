//
//  NutritionService.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 26/02/2025.
//

import Foundation
import Combine
import FirebaseFirestore

class NutritionService: ObservableObject {
    static let shared = NutritionService()
    private let openFoodFactsService = OpenFoodFactsService()
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
    
    func normalize(_ string: String) -> String {
        string
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
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
            quantity: quantity / food.servingSize,
            date: date,
            mealType: mealType,
            source: .favorite,
            unit: food.servingUnit.rawValue
        )
        addFoodEntry(entry)
    }
}


extension NutritionService {
    
    func generateNutriaFoodIfMissing(name: String, brand: String?) async -> NutriaFood? {
        let fullName = brand != nil ? "\(name) \(brand!)" : name
        
        do {
            let nutrition = try await AIService.shared.requestNutritionFromAPI(food: fullName, unit: .gram)
            let now = Date()
            let normalizedName = normalize(name)
            let normalizedBrand = brand?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            let food = NutriaFood(
                id: UUID().uuidString,
                canonicalName: fullName,
                normalizedName: normalizedName,
                brand: brand,
                normalizedBrand: normalizedBrand,
                isGeneric: brand == nil,
                servingSize: nutrition.servingSize,
                servingUnit: nutrition.servingUnit,
                calories: nutrition.calories,
                proteins: nutrition.proteins,
                carbs: nutrition.carbs,
                fats: nutrition.fats,
                fiber: nutrition.fiber,
                source: "gpt-4o-mini",
                createdAt: now
            )
            
            try Firestore.firestore().collection("foods").document(food.id).setData(from: food)
            return food
        } catch {
            print("❌ Erreur GPT ou Firestore : \(error)")
            return nil
        }
    }
    
    private func normalizeString(_ string: String) -> String {
        string
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Calcule la distance de Levenshtein entre deux chaînes
    func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr)
        let b = Array(bStr)
        var dist = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,       // suppression
                        dist[i][j - 1] + 1,       // insertion
                        dist[i - 1][j - 1] + 1    // substitution
                    )
                }
            }
        }

        return dist[a.count][b.count]
    }
    
    func fuzzySearchNutriaFood(name: String, brand: String?) async -> NutriaFood? {
        let normalizedName = normalize(name)
        let normalizedBrand = brand?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let db = Firestore.firestore()
            
            // On récupère un sous-ensemble intelligent de la base
            var query: Query = db.collection("foods").limit(to: 50)

            if let normalizedBrand = normalizedBrand {
                query = query.whereField("normalizedBrand", isEqualTo: normalizedBrand)
            }

            let snapshot = try await query.getDocuments()
            let candidates = try snapshot.documents.compactMap {
                try $0.data(as: NutriaFood.self)
            }

            // Appliquer la distance de Levenshtein
            let filtered = candidates.filter {
                levenshtein($0.normalizedName, normalizedName) <= 2
            }

            return filtered.sorted {
                levenshtein($0.normalizedName, normalizedName) <
                levenshtein($1.normalizedName, normalizedName)
            }.first

        } catch {
            print("❌ Erreur recherche floue Firestore : \(error)")
            return nil
        }
    }

    /// Cherche en base, sinon génère via IA ET stocke dans Firestore
     func fetchNutriaFood(name: String, brand: String?, unit: ServingUnit) async -> NutriaFood? {
       // 1️⃣ normalisation
       let normalizedName = normalize(name)
       let normalizedBrand = brand?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

       // 2️⃣ recherche floue en Firestore
       if let existing = await fuzzySearchNutriaFood(name: normalizedName, brand: normalizedBrand) {
         return existing
       }

       // 3️⃣ pas trouvé → génération + stockage
       do {
         let fullName = brand != nil ? "\(name) \(brand!)" : name
         let nutrition = try await AIService.shared.requestNutritionFromAPI(
           food: fullName,
           unit: unit  // on passe l’unité choisie à l’API
         )

         // création de l’objet complet
         let now = Date()
         let food = NutriaFood(
           id: UUID().uuidString,
           canonicalName: fullName,
           normalizedName: normalizedName,
           brand: brand,
           normalizedBrand: normalizedBrand,
           isGeneric: brand == nil,
           servingSize: nutrition.servingSize,
           servingUnit: nutrition.servingUnit,
           calories: nutrition.calories,
           proteins: nutrition.proteins,
           carbs: nutrition.carbs,
           fats: nutrition.fats,
           fiber: nutrition.fiber,
           source: "gpt-4o",
           createdAt: now
         )

         // write in Firestore
           let snapshot = try await Firestore.firestore()
               .collection("rawNutrition")
               .whereField("foodName", isEqualTo: normalizedName)
               .order(by: "timestamp", descending: true)
               .limit(to: 1)
               .getDocuments()

         return food
       }
       catch {
         print("❌ Erreur IA/Firestore : \(error)")
         return nil
       }
     }
    
    /// Stocke la réponse brute JSON de l'API pour un aliment donné
    func storeRawNutritionJSON(for foodName: String, rawJSON: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("rawNutrition").addDocument(data: [
            "foodName":   foodName,
            "json":       rawJSON,
            "timestamp":  Timestamp(date: Date())
        ])
    }
}

extension NutritionService {

  /// Essaie de lire un JSON brut en base, sinon génère via IA (en réutilisant requestNutritionFromAPI),
  /// le ré-encode en JSON, le stocke et le renvoie.
    func fetchOrGenerateRawJSON(
        for foodName: String,
        unit: ServingUnit
      ) async throws -> String {
        let normalized = foodName
          .lowercased()
          .folding(options: .diacriticInsensitive, locale: .current)

        let db  = Firestore.firestore()
        let col = db.collection("rawNutrition")

        // 🔍 1) recherche
        let snapshot = try await col
          .whereField("normalizedName", isEqualTo: normalized)
          .whereField("unit",           isEqualTo: unit.rawValue)
          .order(by: "timestamp", descending: true)
          .limit(to: 1)
          .getDocuments()

        if let doc = snapshot.documents.first,
           let existingJSON = doc.data()["json"] as? String {
          return existingJSON
        }

        // 🤖 2) sinon appel IA
        let ai = AIService.shared
        let rawJSON = try await ai.requestNutritionRawJSON(food: foodName, unit: unit)

        // 💾 3) stockage du JSON brut
        try await col.addDocument(data: [
          "normalizedName": normalized,
          "unit":           unit.rawValue,
          "json":           rawJSON,
          "timestamp":      Timestamp(date: Date())
        ])

        return rawJSON
      }
}

