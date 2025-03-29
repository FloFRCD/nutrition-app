//
//  FoodPhotoCaptureView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 21/03/2025.
//
import SwiftUI

struct FoodPhotoCaptureView: View {
    let mealType: MealType
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var analysisResult: (String, NutritionInfo)? = nil
    @State private var showingResultSummary = false
    
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
                        VStack {
                            ProgressView()
                                .padding()
                            Text("Analyse en cours...")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button("Analyser cette photo") {
                            analyzePhoto(image)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                        
                        Button("Reprendre une photo") {
                            capturedImage = nil
                        }
                        .padding(.bottom)
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
                        
                        // Afficher l'historique récent
                        RecentFoodScansView( mealType: mealType)
                            .padding(.top, 40)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Photo du repas")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Annuler") {
                    dismiss()
                }
            )
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $capturedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingPhotoLibrary) {
                ImagePicker(image: $capturedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingResultSummary) {
                if let result = analysisResult, let image = capturedImage {
                    FoodAnalysisSummaryView(
                        image: image,
                        foodName: result.0,
                        nutritionInfo: result.1,
                        mealType: mealType,
                        onCompleteAndDismissAll: {
                            // D'abord fermer la vue de résumé
                            self.showingResultSummary = false
                            
                            // Puis informer le JournalViewModel de fermer toutes les sheets
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.journalViewModel.activeSheet = nil
                            }
                            
                            print("🔴 Tentative de fermeture de toutes les vues")
                        }
                    )
                    .environmentObject(journalViewModel)
                }
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Erreur d'analyse"),
                    message: Text(errorMessage ?? "Une erreur est survenue lors de l'analyse de l'image."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func analyzePhoto(_ image: UIImage) {
        isProcessing = true
        
        Task {
            do {
                // Analyse de l'image avec GPT-4
                let result = try await AIService.shared.analyzeFoodPhoto(image)
                
                // Mettre à jour sur le thread principal
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.analysisResult = result
                    self.showingResultSummary = true
                }
            } catch {
                // Gérer l'erreur
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                print("Erreur lors de l'analyse de l'image: \(error)")
            }
        }
    }
}
