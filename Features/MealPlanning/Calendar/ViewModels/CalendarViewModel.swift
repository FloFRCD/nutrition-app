//
//  CalendarViewModel.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation


class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var plannedMeals: [Meal] = []
    
    func fetchMeals(for date: Date) {
        // Cette fonction sera implémentée avec LocalDataManager
    }
    
    func addMeal(_ meal: Meal) {
        // Cette fonction sera implémentée avec LocalDataManager
    }
}
