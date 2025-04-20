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
    
    private var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("❌ Clé API OpenAI non trouvée dans Info.plist.")
        }
        return key
    }



    private let cacheKey = "nutrition_cache"
    
    private func callChatGPT(prompt: String, model: String = "gpt-3.5-turbo") async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model, // Utiliser le modèle passé en paramètre
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
            "fats": nombre en g,
            "fiber": nombre en g
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
    func generateMealPlan(prompt: String, model: String = "gpt-3.5-turbo", systemPrompt: String = "") async throws -> String {
        
        print("PROMPT RÉELLEMENT ENVOYÉ À L'API:")
        print(prompt)
        print("MODÈLE UTILISÉ: \(model)")
        
        // Si un message système est fourni, utilisez-le
        if !systemPrompt.isEmpty {
            let fullPrompt = systemPrompt + "\n\n" + prompt
            return try await callChatGPT(prompt: fullPrompt, model: model)
        } else {
            // Comportement original
            return try await callChatGPT(prompt: prompt, model: model)
        }
    }
    func generateRecipeDetails(recipes: [String]) async throws -> String {
        let recipeNames = recipes.joined(separator: ", ")
        let prompt = """
        Donne-moi les détails complets pour ces recettes: \(recipeNames). Je veux des quantités précises pour 1 personne.
        
        Pour chaque recette, je veux:
        1. La liste précise des ingrédients avec quantités (utilise des nombres décimaux, pas de fractions)
        2. Les valeurs nutritionnelles (calories, protéines, glucides, lipides, fibres)
        3. Les instructions de préparation étape par étape
        
        Réponds au format JSON suivant:
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
        
        let systemPrompt = "Tu es un nutritionniste expert qui fournit des informations précises sur les recettes et leurs valeurs nutritionnelles."
        
        // Utiliser explicitement GPT-4o pour les détails
        return try await generateMealPlan(
            prompt: prompt,
            model: "gpt-4o",
            systemPrompt: systemPrompt
        )
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

extension AIService {
    func analyzeFoodPhoto(_ image: UIImage, userComment: String) async throws -> (String, NutritionInfo) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw OpenAIError.decodingError("Impossible de convertir l'image")
        }

        let base64Image = imageData.base64EncodedString()

        let prompt = """
        Analyse cette photo et identifie les aliments présents et leur quantité. Donne-moi le nom du plat ainsi que les informations nutritionnelles, soit très précis dans l'analyse, c'est très important. \(userComment.isEmpty ? "" : "Voici une précision à prendre en compte : \(userComment).") Réponds uniquement en JSON dans ce format exact: {\"food_name\": \"nom du plat\", \"nutrition\": {\"calories\": nombre, \"proteins\": nombre en g, \"carbs\": nombre en g, \"fats\": nombre en g, \"fiber\": nombre en g}}
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
        }

        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        let jsonString = openAIResponse.choices.first?.message.content ?? ""

        let cleanedJSON = jsonString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw OpenAIError.decodingError("Impossible de convertir la réponse en données JSON")
        }

        struct FoodAnalysisResponse: Codable {
            let food_name: String
            let nutrition: NutritionInfo
        }

        let response = try JSONDecoder().decode(FoodAnalysisResponse.self, from: jsonData)
        return (response.food_name, response.nutrition)
    }
}

