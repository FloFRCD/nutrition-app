//
//  DayliProgressView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct DailyProgressView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Aujourd'hui")
                .font(.headline)
            
            HStack {
                ProgressCard(title: "Calories", current: "1,450", target: "2,000")
                ProgressCard(title: "Protéines", current: "65", target: "120")
                ProgressCard(title: "Eau", current: "1.2", target: "2.5")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}
#Preview {
    DailyProgressView()
}
