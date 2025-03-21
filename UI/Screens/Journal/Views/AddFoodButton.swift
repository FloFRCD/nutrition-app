//
//  AddFoodButton.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//

import Foundation
import SwiftUI

struct AddFoodButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(text)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

// Prévisualisations
struct AddFoodButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            AddFoodButton(icon: "camera", text: "Photo", action: {})
            AddFoodButton(icon: "book", text: "Recette", action: {})
            AddFoodButton(icon: "list.bullet", text: "Ingrédients", action: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
