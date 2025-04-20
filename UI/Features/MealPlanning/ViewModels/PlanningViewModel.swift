//
//  PlanningViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 20/02/2025.
//

import Foundation
import SwiftUI

@MainActor
class PlanningViewModel: ObservableObject {
    @Published var mealSuggestions: [AIMeal] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var localDataManager: LocalDataManager?
    private var aiService: AIService?
    
    func setDependencies(localDataManager: LocalDataManager, aiService: AIService) {
        self.localDataManager = localDataManager
        self.aiService = aiService
        
        // Charger les suggestions sauvegardées immédiatement après l'initialisation des dépendances
        Task {
            await loadSavedSuggestions()
        }
    }
    
    // Nouvelle méthode pour charger les suggestions sauvegardées
    private func loadSavedSuggestions() async {
        guard let localDataManager = localDataManager else { return }
        
        do {
            if let savedSuggestions: [AIMeal] = try await localDataManager.load(forKey: "meal_suggestions_\(getCurrentWeekKey())") {
                await MainActor.run {
                    self.mealSuggestions = savedSuggestions
                    print("✅ Chargement réussi de \(savedSuggestions.count) suggestions sauvegardées")
                }
            }
        } catch {
            print("⚠️ Erreur lors du chargement des suggestions sauvegardées: \(error)")
            // Ne pas assigner d'erreur à self.error car ce n'est pas critique pour l'utilisateur
        }
    }
    
    func generateMealSuggestions(with preferences: MealPreferences) async {
        print("recipesPerType reçu dans ViewModel:", preferences.recipesPerType)
        guard let aiService = aiService else { return }
        
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            // IMPORTANT: Recalculer et forcer le nombre de recettes par type
            var modifiedPreferences = preferences
            let totalSuggestions = 12
            
            // S'assurer que le nombre de types est correct
            if !modifiedPreferences.mealTypes.isEmpty {
                // Forcer le calcul du bon nombre de recettes par type
                let correctRecipesPerType = totalSuggestions / modifiedPreferences.mealTypes.count
                modifiedPreferences.recipesPerType = correctRecipesPerType
                
                print("Correction: Types de repas = \(modifiedPreferences.mealTypes.count), recettes par type = \(correctRecipesPerType)")
            }
            
            // Appel à l’API avec les préférences modifiées
            let isPremium = StoreKitManager.shared.isPremiumUser

            let model = isPremium ? "gpt-4o-mini" : "gpt-3.5-turbo"

            // Exclure les plats précédemment proposés et ceux actuellement affichés
            let previouslySuggested = LocalDataManager.shared.previouslySuggestedMealNames
            let currentlyDisplayed = self.mealSuggestions.map { $0.name.lowercased() }
            let combinedExclusions = Set(previouslySuggested + currentlyDisplayed)
            modifiedPreferences.excludedMealNames = Array(combinedExclusions)


            // Appel API
            let jsonString = try await aiService.generateMealPlan(
                prompt: modifiedPreferences.aiPromptFormat,
                model: model
            )
               
               print("\n=== DÉBUT DU DEBUG ===")
               print("JSON reçu:", jsonString)
               
               // Décodage des suggestions
               guard let jsonData = jsonString.data(using: .utf8) else {
                   throw OpenAIError.decodingError("Impossible de convertir en données")
               }
               
               // Tentative de décodage
               let response: AIMealPlanResponse
               do {
                   response = try JSONDecoder().decode(AIMealPlanResponse.self, from: jsonData)
                   
                   // À ce stade, vous avez vos titres et descriptions
                   print("Suggestions reçues: \(response.meal_suggestions.count)")
                   
                   // Valider les suggestions
                   let correctedSuggestions = validateAndFixSuggestions(response.meal_suggestions, preferences: preferences)
                   
                   // Stockez ces suggestions sur le thread principal
                   await MainActor.run {
                       self.mealSuggestions = correctedSuggestions
                   }
                   
                   // 🧠 Sauvegarde des suggestions récentes pour éviter les doublons futurs
                   LocalDataManager.shared.previouslySuggestedMealNames = correctedSuggestions.map { $0.name.lowercased() }


                   
               } catch {
                   print("Erreur décodage: \(error)")
                   
                   // Essayez de nettoyer le JSON avant de réessayer
                   if let cleanedJson = cleanJSONResponse(jsonString) {
                       do {
                           response = try JSONDecoder().decode(AIMealPlanResponse.self, from: cleanedJson.data(using: .utf8)!)
                           await MainActor.run {
                               self.mealSuggestions = response.meal_suggestions
                           }
                       } catch {
                           throw OpenAIError.decodingError("Impossible de décoder même après nettoyage: \(error)")
                       }
                   } else {
                       throw error
                   }
               }
               
               print("\n=== FIN DU DEBUG ===")
               
               // Sauvegarder les suggestions dans le stockage local
               if let localDataManager = localDataManager {
                   try await localDataManager.save(self.mealSuggestions, forKey: "meal_suggestions_\(getCurrentWeekKey())")
               }
               
           } catch {
               await MainActor.run {
                   print("❌ Erreur lors de la génération:", error)
                   self.error = error
               }
           }
       }
    
    private func validateSuggestions(_ suggestions: [AIMeal], preferences: MealPreferences) {
        // Vérifier les types de repas
        let expectedMealTypesSet = Set(preferences.mealTypes.map { $0.rawValue })
        let suggestedTypes = Set(suggestions.map { $0.type })
        
        // Vérifier qu'il n'y a pas de types de repas non demandés
        for type in suggestedTypes {
            if !expectedMealTypesSet.contains(type) {
                print("⚠️ Type de repas non demandé reçu: \(type)")
            }
        }
        
        // Vérifier les mots bannis dans les titres et descriptions
        for (index, meal) in suggestions.enumerated() {
            for banned in preferences.bannedIngredients {
                if !banned.isEmpty {
                    // Vérifier dans le titre
                    if meal.name.lowercased().contains(banned.lowercased()) {
                        print("⚠️ Suggestion \(index + 1): Mot banni trouvé dans le titre: \(meal.name) contient \(banned)")
                    }
                    
                    // Vérifier dans la description
                    if meal.description.lowercased().contains(banned.lowercased()) {
                        print("⚠️ Suggestion \(index + 1): Mot banni trouvé dans la description: \(meal.description) contient \(banned)")
                    }
                }
            }
        }
    }
    
    // Fonction utilitaire pour nettoyer la réponse JSON
    private func cleanJSONResponse(_ jsonString: String) -> String? {
        // Supprimer tout ce qui n'est pas du JSON valide
        if let startIndex = jsonString.firstIndex(of: "{"),
           let endIndex = jsonString.lastIndex(of: "}") {
            let jsonPart = jsonString[startIndex...endIndex]
            return String(jsonPart)
        }
        return nil
    }

    
    private func determineMealType(from type: String) -> MealType {
        switch type {
        case "Petit-déjeuner":
            return .breakfast
        case "Déjeuner":
            return .lunch
        case "Dîner":
            return .dinner
        case "Collation":
            return .snack
        default:
            print("Type de repas non reconnu:", type)
            return .snack // Valeur par défaut
        }
    }
    
    private func getCurrentWeekKey() -> String {
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        return "\(year)_week\(week)"
    }
    
    // Fonction pour récupérer les détails complets des repas sélectionnés (pour utilisateurs premium)
    func getDetailedRecipes(selectedSuggestions: [AIMeal], preferences: MealPreferences) async {
        guard let aiService = aiService, selectedSuggestions.count <= 3, !selectedSuggestions.isEmpty else {
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Construire le prompt pour les détails des recettes
            let recipeNames = selectedSuggestions.map { $0.name }.joined(separator: ", ")
            let prompt = """
            Développe en détail ces recettes: \(recipeNames).
            Pour chaque recette, fournis:
            1. Liste complète d'ingrédients avec quantités exactes en grammes
            2. Valeurs nutritionnelles par portion (calories, protéines, lipides, glucides)
            3. Instructions de préparation étape par étape
            
            Format JSON:
            {
                "detailed_recipes": [
                    {
                        "name": "Nom de la recette",
                        "ingredients": [
                            {"name": "Nom ingrédient", "quantity": 100, "unit": "g", "calories": 150, "proteines": 8, "glucides": 15, "lipides": 5}
                        ],
                        "instructions": ["Étape 1", "Étape 2"],
                        "nutrients": {"calories": 350, "proteines": 20, "glucides": 40, "lipides": 10}
                    }
                ]
            }
            """
            
            // Appel à l'API avec GPT-4 pour les détails
            // Note: cette partie dépendra de votre implémentation pour les utilisateurs premium
            let jsonString = try await aiService.generateMealPlan(
                prompt: prompt,
                systemPrompt: "Tu es un nutritionniste expert qui génère des détails précis pour des recettes."
            )
            
            // Traitement de la réponse détaillée
            // Ce code devra être adapté selon vos besoins spécifiques pour les détails
            print("Détails de recettes obtenus:", jsonString.prefix(100))
            
            // Décodage et traitement des détails...
            
        } catch {
            print("❌ Erreur lors de la récupération des détails:", error)
            self.error = error
        }
    }
    
    private func validateAndFixSuggestions(_ suggestions: [AIMeal], preferences: MealPreferences) -> [AIMeal] {
        // Regrouper par type
        let groupedByType = Dictionary(grouping: suggestions) { $0.type }
        
        // Créer une nouvelle liste de suggestions équilibrée
        var balancedSuggestions: [AIMeal] = []
        
        // Pour chaque type demandé
        for mealType in preferences.mealTypes.map({ $0.rawValue }) {
            // Obtenir les suggestions pour ce type
            let typeSuggestions = groupedByType[mealType] ?? []
            
            // Si nous avons plus de suggestions que nécessaire, prendre seulement le nombre requis
            if typeSuggestions.count > preferences.recipesPerType {
                balancedSuggestions.append(contentsOf: Array(typeSuggestions.prefix(preferences.recipesPerType)))
            }
            // Si nous avons le bon nombre, les ajouter toutes
            else if typeSuggestions.count == preferences.recipesPerType {
                balancedSuggestions.append(contentsOf: typeSuggestions)
            }
            // Si nous n'avons pas assez, utiliser ce que nous avons et signaler un avertissement
            else {
                balancedSuggestions.append(contentsOf: typeSuggestions)
                print("⚠️ Pas assez de suggestions pour \(mealType): \(typeSuggestions.count)/\(preferences.recipesPerType)")
            }
        }
        
        return balancedSuggestions
    }
}
