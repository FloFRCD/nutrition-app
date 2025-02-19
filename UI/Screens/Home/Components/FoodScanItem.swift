//
//  FoodScanItem.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct FoodScanItem: View {
    let name: String
    let calories: String
    let time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .bold()
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(calories) kcal")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}
#Preview {
    FoodScanItem(name: "Test", calories: "100", time: "10:00")
}
