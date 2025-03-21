//
//  DetailedRecipeViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 16/03/2025.
//

import Foundation
class DetailedRecipesViewModel: ObservableObject {
    @Published var detailedRecipes: [DetailedRecipe] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    
    private let aiService = AIService.shared
    private let localDataManager = LocalDataManager.shared
    
    @MainActor
    func fetchRecipeDetails(for recipes: [AIMeal], userProfile: UserProfile) async {
        isLoading = true
            defer { isLoading = false }
        
        // Vérifier d'abord si les détails sont déjà en cache
        if let cachedDetails = try? await loadCachedDetails(for: recipes) {
            self.detailedRecipes = cachedDetails
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Construire le prompt pour obtenir les détails
            let recipeNames = recipes.map { $0.name }.joined(separator: ", ")
            
            // Calculer les besoins nutritionnels
            let nutritionNeeds = NutritionCalculator.shared.calculateNeeds(for: userProfile)
            
            // Créer la partie du prompt avec le profil utilisateur
            let userProfileInfo = """
            
            PROFIL UTILISATEUR:
            - Age: \(userProfile.age) ans
            - Sexe: \(userProfile.gender.rawValue)
            - Poids: \(userProfile.weight) kg
            - Taille: \(userProfile.height) cm
            - Objectif: \(userProfile.fitnessGoal.rawValue)
            - Niveau d'activité: \(userProfile.activityLevel.rawValue)
            
            BESOINS NUTRITIONNELS QUOTIDIENS:
            - Calories totales: \(Int(nutritionNeeds.totalCalories)) kcal
            - Protéines: \(Int(nutritionNeeds.proteins)) g
            - Glucides: \(Int(nutritionNeeds.carbs)) g
            - Lipides: \(Int(nutritionNeeds.fats)) g
            - Fibres: \(Int(nutritionNeeds.fiber)) g
            
            INSTRUCTIONS SPÉCIFIQUES:
            Prends en compte ces besoins nutritionnels pour adapter les portions et la composition des recettes.
            Si l'objectif est la perte de poids, privilégie les protéines et les fibres.
            Si l'objectif est la prise de muscle, assure un apport suffisant en protéines.
            """
            
            let prompt = """
            Donne-moi les détails complets pour ces recettes: \(recipeNames).
            
            \(userProfileInfo)
            
            Pour chaque recette, je veux:
            1. La liste précise des ingrédients avec quantités (utilise des nombres décimaux, pas de fractions)
            2. Les valeurs nutritionnelles (calories, protéines, glucides, lipides, fibres)
            3. Les instructions de préparation étape par étape
            4. Pour les ingrédients qui ne necessites pas de poid utilise n'utilise pas piece ou unité. 
            Par exemple, "name": "Banane", "quantity": 1, "unit": ""
            5. Pour l'huile et les ingrédients similaires, utilise "càs" (cuillère à soupe) ou "càc" (cuillère à café) plutôt que des millilitres
            6. Pour le type de repas je veux que tu utilise seulement ces 4 termes : Petit-déjeuner, Déjeuner, Collation, Dîner
            
            Réponds au format JSON suivant, sans ajouter de balises markdown ou de formatage supplémentaire:
            {
                "detailed_recipes": [
                    {
                        "name": "Nom de la recette",
                        "description": "Description brève",
                        "type": "Type de repas",
                        "ingredients": [
                            {"name": "Nom ingrédient", "quantity": 100, "unit": "g"}
                        ],
                        "nutritionFacts": {
                            "calories": 350,
                            "proteins": 20,
                            "carbs": 40,
                            "fats": 10,
                            "fiber": 5
                        },
                        "instructions": ["Étape 1", "Étape 2"]
                    }
                ]
            }
            """
            
            // Appel à l'API avec GPT-4o
            let jsonString = try await aiService.generateMealPlan(
                        prompt: prompt,
                        model: "gpt-4o",
                        systemPrompt: "Tu es un nutritionniste expert qui fournit des informations précises. Réponds uniquement avec un JSON brut, sans balises markdown ou autre formatage."
                    )
                    
                    // Nettoyer la réponse pour enlever les balises markdown
                    let cleanedJSON = cleanMarkdownFromJSON(jsonString)
                    print("JSON nettoyé: \(cleanedJSON.prefix(100))...")
                    
                    // Décodage de la réponse avec logs détaillés
                    guard let jsonData = cleanedJSON.data(using: .utf8) else {
                        print("❌ Impossible de convertir le JSON en données")
                        throw NSError(domain: "com.yourapp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON data"])
                    }
                    
                    // Tentative de décodage avec plus de détails sur les erreurs
                    do {
                        let response = try JSONDecoder().decode(DetailedRecipesResponse.self, from: jsonData)
                        print("✅ Décodage réussi: \(response.detailed_recipes.count) recettes détaillées")
                        
                        // Mise à jour des données sur le thread principal
                        await MainActor.run {
                            self.detailedRecipes = response.detailed_recipes
                            print("📱 Interface mise à jour avec les recettes")
                        }
                        
                        // Sauvegarde en cache
                        await cacheDetails(response.detailed_recipes, for: recipes)
                        
                    } catch {
                        print("❌ Erreur de décodage JSON: \(error)")
                        print("🔍 Détails de l'erreur: \(error.localizedDescription)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("Clé manquante: \(key.stringValue), chemin: \(context.codingPath)")
                            case .typeMismatch(let type, let context):
                                print("Type incompatible: attendu \(type), chemin: \(context.codingPath)")
                            case .valueNotFound(let type, let context):
                                print("Valeur manquante pour le type \(type), chemin: \(context.codingPath)")
                            case .dataCorrupted(let context):
                                print("Données corrompues: \(context.debugDescription)")
                            @unknown default:
                                print("Erreur de décodage inconnue")
                            }
                        }
                        
                        // Propager l'erreur pour l'affichage
                        await MainActor.run {
                            self.error = error
                        }
                        throw error
                    }
                    
                } catch {
                    // Assurer que l'erreur est bien assignée sur le thread principal
                    await MainActor.run {
                        self.error = error
                        print("❌ Erreur finale: \(error.localizedDescription)")
                    }
                }
            }

            // Fonction pour nettoyer les balises markdown autour du JSON
            private func cleanMarkdownFromJSON(_ jsonString: String) -> String {
                var cleaned = jsonString
                
                // Rechercher les patterns de markdown courants
                let markdownPatterns = [
                    "```json\n", "```\n", "\n```", "```json", "```"
                ]
                
                for pattern in markdownPatterns {
                    cleaned = cleaned.replacingOccurrences(of: pattern, with: "")
                }
                
                return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            }
    
    // Fonction pour sauvegarder les détails en cache
    private func cacheDetails(_ details: [DetailedRecipe], for recipes: [AIMeal]) async {
        let cacheKey = "detailed_recipes_" + recipes.map { $0.id.uuidString }.joined(separator: "_")
        try? await localDataManager.save(details, forKey: cacheKey)
    }
    
    // Fonction pour charger les détails depuis le cache
    private func loadCachedDetails(for recipes: [AIMeal]) async throws -> [DetailedRecipe]? {
        let cacheKey = "detailed_recipes_" + recipes.map { $0.id.uuidString }.joined(separator: "_")
        return try await localDataManager.load(forKey: cacheKey)
    }
}
