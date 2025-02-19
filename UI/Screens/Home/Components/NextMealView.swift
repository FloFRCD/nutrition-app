//
//  NextMealView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct NextMealView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Prochain repas")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Déjeuner - 12:30")
                        .foregroundColor(.gray)
                    Text("Salade quinoa & poulet")
                        .font(.subheadline)
                        .bold()
                }
                
                Spacer()
                
                Text("550 kcal")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
#Preview {
    NextMealView()
}

