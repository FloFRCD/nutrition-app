//
//  GoalCard.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

//import Foundation
//import SwiftUI
//
//struct GoalCard: View {
//    let goal: UserGoal
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(goal.title)
//                        .font(.headline)
//                    Text(goal.description)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//                Spacer()
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3))
//            )
//        }
//        .buttonStyle(.plain)
//    }
//}
