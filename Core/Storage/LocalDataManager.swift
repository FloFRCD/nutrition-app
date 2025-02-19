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
                userProfile = try await load(forKey: "userProfile")
                meals = try await load(forKey: "meals") ?? []
                weightEntries = try await load(forKey: "weightEntries") ?? []
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
