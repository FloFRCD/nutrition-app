//
//  LocalDataManager.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation

class LocalDataManager: ObservableObject {
    static let shared = LocalDataManager()
    
    @Published var userProfile: UserProfile?
    @Published var meals: [Meal] = []
    @Published var weightEntries: [WeightEntry] = []
    
    private init() {}
    
    func save<T: Encodable>(_ object: T, forKey key: String) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func load<T: Decodable>(forKey key: String) async throws -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
