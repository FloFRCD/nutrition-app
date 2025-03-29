//
//  UserProfileService.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/02/2025.
//

import Foundation

class UserProfileService {
    static let shared = UserProfileService()
    private let userProfileKey = "user_profile"
    
    private init() {}
    
    func getCurrentUserProfile() async -> UserProfile? {
        do {
            return try await LocalDataManager.shared.load(forKey: userProfileKey)
        } catch {
            print("Erreur lors du chargement du profil utilisateur:", error)
            return nil
        }
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        try await LocalDataManager.shared.save(profile, forKey: userProfileKey)
    }
}
