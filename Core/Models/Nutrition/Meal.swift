//
//  Meal.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import Foundation


enum MealType: String, Codable, CaseIterable {
    case breakfast = "Petit-déjeuner"
    case lunch = "Déjeuner"
    case dinner = "Dîner"
    case snack = "Collation"
}

struct Meal: Identifiable, Codable {
    let id: UUID
    var name: String
    var date: Date
    var foods: [Food]
    var type: MealType
    
    var totalCalories: Int {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    init(id: UUID = UUID(), name: String, date: Date, foods: [Food] = [], type: MealType) {
        self.id = id
        self.name = name
        self.date = date
        self.foods = foods
        self.type = type
    }
}

// Enum pour les restrictions alimentaires
enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "Végétarien"
    case vegan = "Végétalien"
    case glutenFree = "Sans gluten"
    case lactoseFree = "Sans lactose"
    case none = "Aucune"
}

struct MealPreferences: Codable {
    var bannedIngredients: [String]
    var preferredIngredients: [String]
    var defaultServings: Int
    var dietaryRestrictions: [DietaryRestriction]
    var numberOfDays: Int
    var mealTypes: [MealType]
    
    var aiPromptFormat: String {
                """
                Génère un plan de repas avec ces contraintes:
                - Nombre de jours: \(numberOfDays)
                - Types de repas: \(mealTypes.map { $0.rawValue }.joined(separator: ", "))
                - Restrictions: \(dietaryRestrictions.map { $0.rawValue }.joined(separator: ", "))
                - Ingrédients bannis: \(bannedIngredients.joined(separator: ", "))
                - Ingrédients préférés: \(preferredIngredients.joined(separator: ", "))
                - Nombre de portions: \(defaultServings)
                - Objectif de poid : 
                
                Utilise des recettes basique et donne des calories précise pour chaque plat. 
                Pour les ingrédient qui nécéssite d'etre cuit, comme les pates ou le riz par exemple, donne toujours la quatité avant cuisson. 
                
                
                
                IMPORTANT: Réponds UNIQUEMENT avec un JSON au format suivant:
                {
                    "days": [
                        {
                            "date": "2024-02-21",
                            "meals": [
                                {
                                    "name": "Nom du repas",
                                    "type": "Type de repas",
                                    "calories": 529,
                                    "ingredients": [
                                        {
                                            "name": "Nom ingrédient",
                                            "quantity": 100,
                                            "unit": "g"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
                
                
                Tu ne retournes que le format JSON. Aucun autre texte. Même pas de phrase avant ou après la reponse.
                Les types de repas doivent être exactement : "Déjeuner" ou "Dîner". Et 'name' doit bien etre le nom du plat
                Les unités doivent être en : "g" (grammes), "ml" (millilitres), càc (cuillere à café), càs (cuillere a soupe), pincée, unité (par exemple, 1 escalope de poulet)
                """
    }
}

struct MealPlan: Codable, Identifiable {
    let id: UUID
    var weekNumber: Int
    var year: Int
    var plannedMeals: [PlannedMeal]
    
    var sortedMeals: [PlannedMeal] {
        plannedMeals.sorted { $0.meal.date < $1.meal.date }
    }
    
    var groupedByDate: [Date: [PlannedMeal]] {
        Dictionary(grouping: plannedMeals) { meal in
            Calendar.current.startOfDay(for: meal.meal.date)
        }
    }
    
    init(id: UUID = UUID(), weekNumber: Int, year: Int, plannedMeals: [PlannedMeal] = []) {
        self.id = id
        self.weekNumber = weekNumber
        self.year = year
        self.plannedMeals = plannedMeals
    }
}

struct PlannedMeal: Codable, Identifiable {
    let id: UUID
    var meal: Meal
    var servings: Int
    var guests: Int
    
    var totalServings: Int {
        servings + guests
    }
    
    init(id: UUID = UUID(), meal: Meal, servings: Int, guests: Int = 0) {
        self.id = id
        self.meal = meal
        self.servings = servings
        self.guests = guests
    }
}
