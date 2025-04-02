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
    private let foodScansKey = "foodScans"
    private var lastSaveTime: Date?
    private let saveDebounceInterval = 0.5
    private var saveLock = NSLock()
    private let customFoodsKey = "customFoods"
    
    private let queue = DispatchQueue(label: "com.yourapp.localdatamanager", qos: .userInitiated)
    
    private init() {
        loadInitialData()
    }
    
    private func loadInitialData() {
        Task {
            do {
                if let profile: UserProfile = try await load(forKey: "userProfile") {
                    print("Profile chargé:", profile)
                    // Explicitement revenir sur le main thread pour mettre à jour @Published
                    DispatchQueue.main.async {
                        self.userProfile = profile
                    }
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
}

extension LocalDataManager {
    // Charger les recettes sélectionnées
    func loadSelectedRecipes() async throws -> [DetailedRecipe] {
        return try await load(forKey: "selected_recipes") ?? []
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
        
        saveLock.lock()
            defer { saveLock.unlock() }
            // Capturer la pile d'appels
            let callStack = Thread.callStackSymbols
            
            print("SAVE CALL STACK:")
            for (index, call) in callStack.prefix(8).enumerated() {
                print("  \(index): \(call)")
            }
        // Éviter les sauvegardes trop rapprochées
        let now = Date()
        if let lastSave = lastSaveTime, now.timeIntervalSince(lastSave) < saveDebounceInterval {
            print("⚠️ Sauvegarde ignorée - trop rapprochée de la précédente (\(now.timeIntervalSince(lastSave)) sec)")
            return
        }
        
        lastSaveTime = now
        
        // Ajouter l'ID du thread pour débogage
        let threadId = Thread.current.description
        print("💾 [Thread: \(threadId)] saveFoodEntries appelé avec \(entries.count) entrées")
        
        // Reste de votre code de sauvegarde...
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(entries)
            UserDefaults.standard.set(data, forKey: "foodEntries")
            UserDefaults.standard.synchronize()
            print("✅ Entrées du journal sauvegardées : \(entries)")
        } catch {
            print("❌ Erreur lors de la sauvegarde des entrées du journal : \(error)")
        }
    }
    
    
    func loadFoodEntries() -> [FoodEntry]? {
        print("func loadFoodEntries() -> [FoodEntry]?")
        guard let data = UserDefaults.standard.data(forKey: "foodEntries") else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        print("let entries = try decoder.decode([FoodEntry].self, from: data)")
        do {
            let entries = try decoder.decode([FoodEntry].self, from: data)
            // Breakpoint et po ici
            print("✅ Entrées du journal chargées : \(entries)")
            return entries
        } catch {
            print("❌ Erreur lors du chargement des entrées du journal : \(error)")
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
    
    func clearFoodEntries() {
        UserDefaults.standard.removeObject(forKey: "foodEntries")
        UserDefaults.standard.synchronize()
        print("✅ Toutes les entrées du journal ont été effacées")
    }
}

extension LocalDataManager {

    
    func saveCustomFoods(_ customFoods: [CustomFood]) {
        saveLock.lock()
        defer { saveLock.unlock() }
        
        print("💾 saveCustomFoods appelé avec \(customFoods.count) aliments personnalisés")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(customFoods)
            UserDefaults.standard.set(data, forKey: customFoodsKey)
            UserDefaults.standard.synchronize()
            print("✅ Aliments personnalisés sauvegardés")
        } catch {
            print("❌ Erreur lors de la sauvegarde des aliments personnalisés : \(error)")
        }
    }
    
    func loadCustomFoods() -> [CustomFood] {
        guard let data = UserDefaults.standard.data(forKey: customFoodsKey) else {
            print("⚠️ Aucun aliment personnalisé trouvé")
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let customFoods = try decoder.decode([CustomFood].self, from: data)
            print("✅ \(customFoods.count) aliments personnalisés chargés")
            return customFoods
        } catch {
            print("❌ Erreur lors du chargement des aliments personnalisés : \(error)")
            return []
        }
    }
    
    func addCustomFood(_ customFood: CustomFood) {
        var customFoods = loadCustomFoods()
        
        // Vérifier si l'aliment existe déjà (par ID)
        if !customFoods.contains(where: { $0.id == customFood.id }) {
            customFoods.append(customFood)
            saveCustomFoods(customFoods)
            print("✅ Aliment personnalisé ajouté : \(customFood.name)")
        } else {
            print("ℹ️ L'aliment personnalisé existe déjà : \(customFood.name)")
        }
    }
    
    func removeCustomFood(id: UUID) {
        var customFoods = loadCustomFoods()
        customFoods.removeAll { $0.id == id }
        saveCustomFoods(customFoods)
        print("✅ Aliment personnalisé supprimé")
    }
    
    func updateCustomFood(_ customFood: CustomFood) {
        var customFoods = loadCustomFoods()
        if let index = customFoods.firstIndex(where: { $0.id == customFood.id }) {
            customFoods[index] = customFood
            saveCustomFoods(customFoods)
            print("✅ Aliment personnalisé mis à jour : \(customFood.name)")
        }
    }
}

extension LocalDataManager {
    
    func saveFoodScan(_ scan: FoodScan) {
        var scans = loadFoodScans()
        scans.append(scan)
        // Limiter à 20 scans maximum
        if scans.count > 20 {
            scans.removeFirst(scans.count - 20)
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(scans)
            UserDefaults.standard.set(data, forKey: foodScansKey)
            UserDefaults.standard.synchronize()
            
            // Mettre à jour la propriété publiée
            DispatchQueue.main.async {
                self.recentScans = scans
            }
            
            print("✅ Scan alimentaire sauvegardé : \(scan.foodName)")
        } catch {
            print("❌ Erreur lors de la sauvegarde du scan : \(error)")
        }
    }
    
    func loadFoodScans() -> [FoodScan] {
        guard let data = UserDefaults.standard.data(forKey: foodScansKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let scans = try decoder.decode([FoodScan].self, from: data)
            return scans
        } catch {
            print("❌ Erreur lors du chargement des scans : \(error)")
            return []
        }
    }
    
    func getRecentFoodScans(limit: Int = 5) -> [FoodScan] {
        let allScans = loadFoodScans()
        // Trier par date décroissante et limiter au nombre demandé
        return Array(allScans.sorted(by: { $0.date > $1.date }).prefix(limit))
    }
    func updateWeight(to newWeight: Double) {
        userProfile?.weight = newWeight
        saveProfile()
    }

    func updateTargetWeight(to newTarget: Double) {
        userProfile?.targetWeight = newTarget
        saveProfile()
    }
    
    func saveProfile() {
        Task {
            if let profile = userProfile {
                do {
                    try await save(profile, forKey: "userProfile")
                    print("✅ Profil sauvegardé avec succès depuis LocalDataManager")
                } catch {
                    print("❌ Erreur lors de la sauvegarde du profil :", error)
                }
            }
        }
    }
    
}
