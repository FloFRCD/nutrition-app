//
//  ProgressCard.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ProgressCard: View {
    let title: String
    let current: String
    let target: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(current)
                .font(.title3)
                .bold()
            Text("/ \(target)")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
#Preview {
    ProgressCard(title: "Calories", current: "1200", target: "1500")
}
