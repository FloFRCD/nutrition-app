'//
//  CalendarView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUICore
import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        VStack {
            DatePicker(
                "Sélectionner une date",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            
            List(viewModel.plannedMeals) { meal in
                Text(meal.name)
                    .padding()
            }
        }
        .padding()
    }
}
