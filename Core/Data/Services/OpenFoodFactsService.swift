//
//  OpenFoodFactsService.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 26/02/2025.
//

import Foundation
import Combine

// MARK: - Models

struct OpenFoodFactsProduct: Codable, Identifiable {
        var id: String { code }  // Utilise le code comme ID
        let code: String
        let product: ProductDetails
    
    struct ProductDetails: Codable {
        let productName: String?
        let nutriments: Nutriments?
        let ingredients: [Ingredient]?
        
        enum CodingKeys: String, CodingKey {
            case productName = "product_name"
            case nutriments
            case ingredients = "ingredients"  // Cette clé devrait pointer vers le tableau d'objets Ingredient
        }
    }
    
    struct Nutriments: Codable {
        let energyKcal100g: Double?
        let proteins100g: Double?
        let carbohydrates100g: Double?
        let fat100g: Double?
        let fiber100g: Double?
        
        enum CodingKeys: String, CodingKey {
            case energyKcal100g = "energy-kcal_100g"
            case proteins100g = "proteins_100g"
            case carbohydrates100g = "carbohydrates_100g"
            case fat100g = "fat_100g"
            case fiber100g = "fiber_100g"
        }
    }
    
    struct Ingredient: Codable {
        let id: String
        let name: String?
        
        // Ajoutez d'autres propriétés selon les besoins
    }
}

// MARK: - Error Handling

enum OpenFoodFactsError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    case apiError(String)
}

// MARK: - Service

class OpenFoodFactsService {
    private let baseURL = "https://world.openfoodfacts.org/api/v0"
    private let session = URLSession.shared
    
    // Fonction pour rechercher un produit par code-barres
    func getProduct(barcode: String) -> AnyPublisher<OpenFoodFactsProduct, OpenFoodFactsError> {
        guard let url = URL(string: "\(baseURL)/product/\(barcode).json") else {
            return Fail(error: OpenFoodFactsError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .mapError { OpenFoodFactsError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<OpenFoodFactsProduct, OpenFoodFactsError> in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    return Fail(error: OpenFoodFactsError.apiError("Invalid response")).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: OpenFoodFactsProduct.self, decoder: JSONDecoder())
                    .mapError { OpenFoodFactsError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // Fonction pour rechercher un ingrédient par nom
    func searchIngredient(name: String) -> AnyPublisher<[OpenFoodFactsProduct], OpenFoodFactsError> {
        // Échapper les caractères spéciaux de l'URL
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search?search_terms=\(encodedName)&page_size=5&json=1") else {
            return Fail(error: OpenFoodFactsError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .mapError { OpenFoodFactsError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<[OpenFoodFactsProduct], OpenFoodFactsError> in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    return Fail(error: OpenFoodFactsError.apiError("Invalid response")).eraseToAnyPublisher()
                }
                
                // La structure de la réponse pour une recherche est différente
                // Il faudrait adapter le décodage en fonction de la réponse réelle
                struct SearchResponse: Codable {
                    let products: [OpenFoodFactsProduct]
                }
                
                return Just(data)
                    .decode(type: SearchResponse.self, decoder: JSONDecoder())
                    .map { $0.products }
                    .mapError { OpenFoodFactsError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // Fonction utilitaire pour calculer les valeurs nutritionnelles à partir d'une quantité donnée
    func calculateNutrition(from product: OpenFoodFactsProduct.ProductDetails, quantityInGrams: Double) -> NutritionValues? {
        guard let nutriments = product.nutriments else { return nil }
        
        let factor = quantityInGrams / 100.0 // Les valeurs dans la base sont pour 100g
        
        return NutritionValues(
            calories: (nutriments.energyKcal100g ?? 0) * factor,
            proteins: (nutriments.proteins100g ?? 0) * factor,
            carbohydrates: (nutriments.carbohydrates100g ?? 0) * factor,
            fats: (nutriments.fat100g ?? 0) * factor,
            fiber: (nutriments.fiber100g ?? 0) * factor
        )
    }
}
