//
//  ScanView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ScanView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Placeholder pour la caméra
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                    )
                
                Button(action: {
                    // Action de scan à implémenter
                }) {
                    Text("Scanner un aliment")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Scanner")
        }
    }
}
#Preview {
    ScanView()
}
