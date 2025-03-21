//
//  LocalDataManager.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

enum LocalDataError: Error {
    case saveError(String)
    case loadError(String)
    case dataNotFound
    case decodingError(String)
}

class LocalDataManager: ObservableObject {
    static let shared = LocalDataManager()
    
    @Published var userProfile: UserProfile?
    @Published var meals: [Meal] = []
    @Published var weightEntries: [WeightEntry] = []
    @Published var recentScans: [FoodScan] = []
    
    private let queue = DispatchQueue(label: "com.yourapp.localdatamanager", qos: .userInitiated)
    
    private init() {
        loadInitialData()
    }
    
    private func loadInitialData() {
        Task {
            do {
                if let profile: UserProfile = try await load(forKey: "userProfile") {
                    print("Profile chargé:", profile) // Debug pour vérifier les valeurs
                    userProfile = profile
                }
            } catch {
                print("Error loading initial data: \(error)")
            }
        }
    }
    
    func save<T: Encodable>(_ object: T, forKey key: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    let data = try encoder.encode(object)
                    UserDefaults.standard.set(data, forKey: key)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: LocalDataError.saveError(error.localizedDescription))
                }
            }
        }
    }
    
    func load<T: Decodable>(forKey key: String) async throws -> T? {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                guard let data = UserDefaults.standard.data(forKey: key) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let object = try decoder.decode(T.self, from: data)
                    continuation.resume(returning: object)
                } catch {
                    continuation.resume(throwing: LocalDataError.decodingError(error.localizedDescription))
                }
            }
        }
    }
    
    func delete(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // Méthode utilitaire pour sauvegarder rapidement l'état complet
    func saveCurrentState() async {
        do {
            if let profile = userProfile {
                try await save(profile, forKey: "userProfile")
            }
            try await save(meals, forKey: "meals")
            try await save(weightEntries, forKey: "weightEntries")
        } catch {
            print("Error saving current state: \(error)")
        }
    }
}

// Methodes gestion des repas
extension LocalDataManager {
    func addMeal(_ meal: Meal) async throws {
        meals.append(meal)
        try await save(meals, forKey: "meals")
    }
    
    func updateMeal(_ meal: Meal) async throws {
        if let index = meals.firstIndex(where: { $0.id == meal.id }) {
            meals[index] = meal
            try await save(meals, forKey: "meals")
        }
    }
    
    func deleteMeal(_ mealId: UUID) async throws {
        meals.removeAll { $0.id == mealId }
        try await save(meals, forKey: "meals")
    }
    
    func getMealsForDate(_ date: Date) -> [Meal] {
        let calendar = Calendar.current
        return meals.filter { meal in
            calendar.isDate(meal.date, inSameDayAs: date)
        }
    }
}

// Methodes suivi de poid
extension LocalDataManager {
    func addWeightEntry(_ entry: WeightEntry) async throws {
        weightEntries.append(entry)
        try await save(weightEntries, forKey: "weightEntries")
    }
    
    func getWeightHistory(for period: DateInterval) -> [WeightEntry] {
        return weightEntries
            .filter { period.contains($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    func getLatestWeight() -> WeightEntry? {
        return weightEntries.max(by: { $0.date < $1.date })
    }
}

extension LocalDataManager {
    // Charger les recettes sélectionnées
    func loadSelectedRecipes() async throws -> [DetailedRecipe] {
        return try await load(forKey: "selected_recipes") ?? []
    }
    
    func loadSavedRecipes() -> [DetailedRecipe] {
        // Récupérer les recettes depuis UserDefaults ou une autre source de données
        
        // Par exemple, si vous stockez vos recettes dans UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "savedRecipes") else {
            return []
        }
        
        do {
            let recipes = try JSONDecoder().decode([DetailedRecipe].self, from: data)
            return recipes
        } catch {
            print("Erreur lors du décodage des recettes: \(error)")
            return []
        }
    }
    
    // Sauvegarder les recettes sélectionnées
    func saveSelectedRecipes(_ recipes: [DetailedRecipe]) async throws {
        try await save(recipes, forKey: "selected_recipes")
    }
    
    
    // Ajouter une recette aux sélections
    func addToSelection(_ recipe: DetailedRecipe) async {
        do {
            var selectedRecipes = try await loadSelectedRecipes()
            
            // Vérifier si la recette n'est pas déjà dans les sélections
            if !selectedRecipes.contains(where: { $0.name == recipe.name }) {
                selectedRecipes.append(recipe)
                try await saveSelectedRecipes(selectedRecipes)
                print("✅ Recette ajoutée aux sélections: \(recipe.name)")
            }
        } catch {
            print("❌ Erreur lors de l'ajout aux sélections: \(error)")
        }
    }
    
    // Retirer une recette des sélections
    func removeFromSelection(_ recipe: DetailedRecipe) async {
        do {
            var selectedRecipes = try await loadSelectedRecipes()
            selectedRecipes.removeAll { $0.name == recipe.name }
            try await saveSelectedRecipes(selectedRecipes)
            print("✅ Recette retirée des sélections: \(recipe.name)")
        } catch {
            print("❌ Erreur lors du retrait des sélections: \(error)")
        }
    }
    
    // Vérifier si une recette est sélectionnée
    func isRecipeSelected(_ recipe: DetailedRecipe) async -> Bool {
        do {
            let selectedRecipes = try await loadSelectedRecipes()
            return selectedRecipes.contains(where: { $0.name == recipe.name })
        } catch {
            print("❌ Erreur lors de la vérification des sélections: \(error)")
            return false
        }
    }
    
    // Basculer l'état de sélection d'une recette
    func toggleRecipeSelection(_ recipe: DetailedRecipe) async {
        if await isRecipeSelected(recipe) {
            await removeFromSelection(recipe)
        } else {
            await addToSelection(recipe)
        }
    }
    
    // Dans LocalDataManager.swift
    func saveFoodEntries(_ entries: [FoodEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: "foodEntries")
        } catch {
            print("Erreur lors de la sauvegarde des entrées du journal : \(error)")
        }
    }

    func loadFoodEntries() -> [FoodEntry]? {
        guard let data = UserDefaults.standard.data(forKey: "foodEntries") else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([FoodEntry].self, from: data)
        } catch {
            print("Erreur lors du chargement des entrées du journal : \(error)")
            return nil
        }
    }
}

extension LocalDataManager {
    var savedRecipes: [Recipe]? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "savedRecipes") else {
                return nil
            }
            
            do {
                return try JSONDecoder().decode([Recipe].self, from: data)
            } catch {
                print("Erreur lors du chargement des recettes : \(error)")
                return nil
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: "savedRecipes")
            } catch {
                print("Erreur lors de la sauvegarde des recettes : \(error)")
            }
        }
    }
}
