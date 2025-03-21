//
//  FoodPhotoCaptureView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//
import SwiftUI

struct FoodPhotoCaptureView: View {
    let mealType: MealType
    let onImageCaptured: (UIImage) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    // Image capturée
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()
                    
                    if isProcessing {
                        ProgressView("Analyse en cours...")
                            .padding()
                    } else {
                        Button("Analyser cette photo") {
                            isProcessing = true
                            onImageCaptured(image)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                } else {
                    // Aucune image
                    VStack(spacing: 30) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Prenez en photo votre repas\npour obtenir sa valeur nutritionnelle")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        VStack(spacing: 15) {
                            Button("Prendre une photo") {
                                showingCamera = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Choisir dans la galerie") {
                                showingPhotoLibrary = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Photo du repas")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $capturedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingPhotoLibrary) {
                ImagePicker(image: $capturedImage, sourceType: .photoLibrary)
            }
        }
    }
}

// Prévisualisations
struct FoodPhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        FoodPhotoCaptureView(mealType: .lunch, onImageCaptured: { _ in })
    }
}
