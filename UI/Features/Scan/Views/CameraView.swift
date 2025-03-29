//
//  CameraView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import Foundation
import SwiftUICore
import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        VStack {
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Placeholder pour la caméra
                Rectangle()
                    .fill(Color.gray)
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay(
                        Image(systemName: "camera")
                            .font(.largeTitle)
                    )
            }
            
            Button(action: {
                viewModel.isCapturing = true
            }) {
                Text("Prendre une photo")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isCapturing = false
    
    func captureImage() {
        // Cette fonction sera implémentée avec AVFoundation
    }
}
