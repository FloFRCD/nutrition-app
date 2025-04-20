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
    @State private var userComment: String = ""
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var analysisResult: (String, NutritionInfo)? = nil
    @State private var showingResultSummary = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()

                    TextField("Ajouter une précision (ex: tartiflette sans crème)", text: $userComment)
                        .padding()
                        .cornerRadius(12)
                        .foregroundColor(AppTheme.primaryText)
                        .padding(.horizontal)

                    if isProcessing {
                        VStack {
                            ProgressView()
                                .padding()
                            Text("Analyse en cours...")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    } else {
                        Button("Analyser cette photo") {
                            analyzePhoto(image, userComment: userComment)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.actionAccent)
                        .padding()

                        Button("Reprendre une photo") {
                            capturedImage = nil
                            userComment = ""
                        }
                        .padding(.bottom)
                    }

                    Text("⚠️ Nous utilisons l’une des meilleures intelligences artificielles au monde pour analyser vos photos. Cependant, l’analyse par image reste la méthode la moins précise, comme pour toutes les applications du marché. /nPour des résultats plus fiables, privilégiez le scan de code-barres, les ingrédients personnalisés ou notre base de données intégrée.")
                        .font(.caption)
                        .foregroundColor(AppTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 30) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primaryBlue)

                        Text("Prenez en photo votre repas\npour obtenir sa valeur nutritionnelle")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppTheme.primaryText)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            Button(action: {
                                showingCamera = true
                            }) {
                                Text("Prendre une photo")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.actionButtonGradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            Button(action: {
                                showingPhotoLibrary = true
                            }) {
                                Text("Choisir dans la galerie")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.secondaryButtonBackground)
                                    .foregroundColor(AppTheme.primaryText)
                                    .cornerRadius(12)
                            }
                            
                            Text("⚠️ Nous utilisons l’une des meilleures intelligences artificielles au monde pour analyser vos photos. Cependant, l’analyse par image reste la méthode la moins précise, comme pour toutes les applications du marché.\n\nPour des résultats plus fiables, privilégiez le scan de code-barres, les ingrédients personnalisés ou notre base de données intégrée.")
                                .font(.caption)
                                .foregroundColor(AppTheme.tertiaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                        }
                        .padding(.horizontal)

                        //TODO: Historique des scans photo
//                        RecentFoodScansView(mealType: mealType)
//                            .padding(.top, 40)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }


                Spacer()
            }
            .background(Color.white.ignoresSafeArea())
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
                            self.showingResultSummary = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.journalViewModel.activeSheet = nil
                            }
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

    private func analyzePhoto(_ image: UIImage, userComment: String) {
        isProcessing = true

        Task {
            do {
                let result = try await AIService.shared.analyzeFoodPhoto(image, userComment: userComment)
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.analysisResult = result
                    self.showingResultSummary = true
                }
            } catch {
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

