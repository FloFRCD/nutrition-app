//
//  ProgressBar.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct ProgressBar: View {
    var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .frame(width: geometry.size.width, height: 20)
                    .opacity(0.1)
                    .foregroundColor(color)
                    .cornerRadius(10)
                
                // Progress
                Rectangle()
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: 20)
                    .foregroundColor(color)
                    .cornerRadius(10)
                
                // Label
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .frame(width: geometry.size.width, alignment: .center)
            }
        }
        .frame(height: 20)
    }
}
