//
//  AIService.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import StoreKit


class AIService {
    static let shared = AIService()
    private let apiKey = "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"
    private let cacheKey = "nutrition_cache"
    
    private func callChatGPT(prompt: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        // Debug
        print("Status code: \(httpResponse.statusCode)")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw response: \(jsonString)")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return openAIResponse.choices.first?.message.content ?? ""
    }
    
    func requestNutritionFromAPI(food: String) async throws -> NutritionInfo {
        let prompt = """
        Analyse les informations nutritionnelles pour : \(food)
        Réponds uniquement en JSON, dans ce format exact :
        {
            "calories": nombre,
            "proteins": nombre en g,
            "carbs": nombre en g,
            "fats": nombre en g
        }
        """
        
        let jsonString = try await callChatGPT(prompt: prompt)
        // Nettoyer la réponse pour s'assurer qu'elle ne contient que du JSON
        let cleanedJSON = jsonString.replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw OpenAIError.decodingError("Impossible de convertir la réponse en données JSON")
        }
        
        return try JSONDecoder().decode(NutritionInfo.self, from: jsonData)
    }
    
    func analyzeNutrition(food: String) async throws -> NutritionInfo {
            // Vérifier le cache d'abord
            if let cached = await getCachedNutrition(for: food) {
                return cached
            }
            
            let nutrition = try await requestNutritionFromAPI(food: food)
            await cacheNutrition(nutrition, for: food)
            return nutrition
        }
    
    private func getCachedNutrition(for food: String) async -> NutritionInfo? {
            guard let cached: [String: NutritionInfo] = try? await LocalDataManager.shared.load(forKey: cacheKey) else {
                return nil
            }
            return cached[food.lowercased()]
        }
        
        private func cacheNutrition(_ nutrition: NutritionInfo, for food: String) async {
            var cached: [String: NutritionInfo] = (try? await LocalDataManager.shared.load(forKey: cacheKey)) ?? [:]
            cached[food.lowercased()] = nutrition
            try? await LocalDataManager.shared.save(cached, forKey: cacheKey)
        }
}

extension AIService {
    func generateMealPlan(prompt: String, systemPrompt: String = "") async throws -> String {
        // Si un message système est fourni, utilisez-le
        if !systemPrompt.isEmpty {
            // Implémentez la logique pour inclure le message système
            // Soit en modifiant callChatGPT, soit en adaptant le prompt ici
            let fullPrompt = systemPrompt + "\n\n" + prompt
            return try await callChatGPT(prompt: fullPrompt)
        } else {
            // Comportement original
            return try await callChatGPT(prompt: prompt)
        }
    }
    
    func adjustMealPortions(meal: Meal, targetCalories: Double) -> Meal {
        // 1. Calculer les calories actuelles du repas
        let currentCalories = Double(meal.totalCalories)
        
        // Si le repas n'a pas de calories, on ne peut pas ajuster
        guard currentCalories > 0 else { return meal }
        
        // 2. Calculer le facteur d'ajustement
        let adjustmentFactor = targetCalories / currentCalories
        
        // 3. Créer une copie du repas avec les quantités ajustées
        var adjustedMeal = meal
        var adjustedFoods: [Food] = []

        for food in meal.foods {
            // Créer une nouvelle instance de Food avec les valeurs ajustées
            let adjustedFood = Food(
                id: food.id,
                name: food.name,
                calories: Int(Double(food.calories) * adjustmentFactor),
                proteins: food.proteins * adjustmentFactor,
                carbs: food.carbs * adjustmentFactor,
                fats: food.fats * adjustmentFactor,
                servingSize: food.servingSize * adjustmentFactor,
                servingUnit: food.servingUnit,
                image: food.image
            )
            
            adjustedFoods.append(adjustedFood)
        }

        adjustedMeal.foods = adjustedFoods
        return adjustedMeal
    }

    // Fonction pour ajuster un plan de repas complet
    func adjustMealPlan(mealPlan: MealPlan, userProfile: UserProfile) -> MealPlan {
        let nutritionNeeds = NutritionCalculator.shared.calculateNeeds(for: userProfile)
        
        // Calculer les calories cibles par type de repas
        let breakfastCalories = Double(nutritionNeeds.targetCalories) * 0.20
        let lunchCalories = Double(nutritionNeeds.targetCalories) * 0.27
        let dinnerCalories = Double(nutritionNeeds.targetCalories) * 0.25
        let snackCalories = Double(nutritionNeeds.targetCalories) * 0.10
        
        var adjustedMealPlan = mealPlan
        var adjustedPlannedMeals: [PlannedMeal] = []
        
        for plannedMeal in mealPlan.plannedMeals {
            var adjustedPlannedMeal = plannedMeal
            
            // Sélectionner les calories cibles en fonction du type de repas
            let targetCalories: Double
            switch plannedMeal.meal.type {
            case .breakfast:
                targetCalories = breakfastCalories
            case .lunch:
                targetCalories = lunchCalories
            case .dinner:
                targetCalories = dinnerCalories
            case .snack:
                targetCalories = snackCalories
            }
            
            // Ajuster les portions
            adjustedPlannedMeal.meal = adjustMealPortions(meal: plannedMeal.meal, targetCalories: targetCalories)
            adjustedPlannedMeals.append(adjustedPlannedMeal)
        }
        
        adjustedMealPlan.plannedMeals = adjustedPlannedMeals
        return adjustedMealPlan
    }
}

// Structures pour la réponse OpenAI
struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    let systemFingerprint: String?
    let serviceTier: String?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
        case serviceTier = "service_tier"
    }
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let logprobs: String?
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
    let refusal: String?
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

enum OpenAIError: Error {
    case invalidResponse
    case networkError(String)
    case decodingError(String)
    case apiError(String)
}

