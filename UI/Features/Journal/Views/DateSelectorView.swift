//
//  DateSelectorView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import Foundation
import SwiftUI

struct DateSelectorView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Button(action: { moveDate(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 8)
            
            Spacer()
            
            Text(dateFormatter.string(from: selectedDate))
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { moveDate(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8) // Réduction de l'épaisseur verticale
        .padding(.horizontal, 12)
        .background(Color.clear)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2) // Ombre très subtile
    }
    
    
    private func moveDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        // Définir la locale française
        formatter.locale = Locale(identifier: "fr_FR")
        
        // Si c'est aujourd'hui, afficher "Aujourd'hui"
        if Calendar.current.isDateInToday(selectedDate) {
            class CustomFormatter: DateFormatter {
                override func string(from date: Date) -> String {
                    return "Aujourd'hui"
                }
            }
            
            return CustomFormatter()
        }
        // Sinon afficher le jour et la date
        return formatter.with {
            $0.dateFormat = "EEEE d MMMM"
        }
    }
}


// Extension utilitaire pour les formatters (inchangée)
extension DateFormatter {
    func with(_ configure: (inout DateFormatter) -> Void) -> DateFormatter {
        var copy = self
        configure(&copy)
        return copy
    }
}

// Prévisualisations
struct DateSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DateSelectorView(selectedDate: .constant(Date()))
            .previewLayout(.sizeThatFits)
    }
}
