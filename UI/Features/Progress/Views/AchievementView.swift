//
//  AchievementView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUICore
import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()
    
    var body: some View {
        List(viewModel.achievements) { achievement in
            HStack {
                Image(systemName: achievement.icon)
                    .foregroundColor(achievement.isUnlocked ? Color.green : Color.gray)
                
                VStack(alignment: .leading) {
                    Text(achievement.name)
                        .font(.headline)
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if achievement.isUnlocked {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
    }
}
