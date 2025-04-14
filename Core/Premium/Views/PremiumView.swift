//
//  PremiumView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import SwiftUI

struct PremiumView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PremiumViewModel()
    @State private var showFeaturesSheet = false
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    var body: some View {
        ZStack {
            AppBackgroundDark().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)
                    
                    // Image encadrée
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.primaryButtonGradient, lineWidth: 3)
                        .frame(width: 220, height: 220)
                        .overlay(
                            Image("premiumbackground")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(8)
                        )
                        .shadow(color: AppTheme.vibrantGreen.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Titre
                    Text("Nutria PREMIUM")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    // Accroche
                    Text("Pour ceux qui veulent le meilleur")
                        .font(.body)
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Bouton voir fonctionnalités
                    Button(action: {
                        showFeaturesSheet.toggle()
                    }) {
                        Text("Voir les fonctionnalités débloquées")
                            .font(.subheadline)
                            .underline()
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 4)
                    }
                    
                    // Abonnements
                    VStack(spacing: 16) {
                        PremiumGradientButton(
                            title: "1,49€ / semaine",
                            subtitle: "Abonnement flexible, sans engagement",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [AppTheme.logoPurple, AppTheme.primaryBlue]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            action: {
                                Task {
                                    guard let package = viewModel.offerings?.current?.weekly else {
                                        print("❌ Package weekly non trouvé")
                                        return
                                    }
                                    await viewModel.purchase(package: package)
                                }
                            }
                        )
                        .disabled(viewModel.offerings?.current?.weekly == nil)
                        
                        PremiumGradientButton(
                            title: "4,99€ / mois",
                            subtitle: "Moins de 0,17€ par jour pour atteindre tes objectifs",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [AppTheme.primaryBlue, AppTheme.vibrantGreen]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            action: {
                                Task {
                                    if let package = viewModel.offerings?.current?.monthly {
                                        await viewModel.purchase(package: package)
                                    } else {
                                        print("❌ Package mensuel non trouvé")
                                    }
                                }
                            }
                        )
                        
                        PremiumGradientButton(
                            title: "44,99€ / an",
                            subtitle: "Économisez 25% (au lieu de 59,88€)",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [AppTheme.vibrantGreen, AppTheme.lightYellow]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            action: {
                                Task {
                                    if let package = viewModel.offerings?.current?.annual {
                                        await viewModel.purchase(package: package)
                                    }
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Liens obligatoires (Apple)
                    HStack {
                        Link("Confidentialité", destination: URL(string: "https://flofrcd.github.io/politique-confidentialite")!)
                            .foregroundColor(.gray)
                            .font(.footnote)
                        
                        Spacer()
                        
                        Link("Conditions d'utilisation", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            
            // Bouton de fermeture
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(16)
                    }
                }
                Spacer()
            }
        }
        .task {
            await viewModel.loadProducts()
            print("📦 Offres chargées : \(String(describing: viewModel.offerings))")
        }
        .sheet(isPresented: $showFeaturesSheet) {
            PremiumFeaturesSheet()
        }
        .onChange(of: storeKitManager.currentSubscription) { newValue in
            if newValue != .free {
                dismiss()
            }
        }
    }
}



#Preview {
    PremiumView()
}
