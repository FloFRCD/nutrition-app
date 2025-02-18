//
//  ProgressBar.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI

struct ProgressBar: View {
    let value: Double
    let total: Double
    var color: Color = .blue
    
    private var progress: Double {
        min(max(value / total, 0), 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color.opacity(0.3))
                
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .cornerRadius(8)
        .frame(height: 8)
    }
}
