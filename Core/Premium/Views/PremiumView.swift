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
    @State private var isPurchasing = false
    
    var body: some View {
        ZStack {
            AppBackgroundDark().ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 20)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppTheme.primaryButtonGradient, lineWidth: 3)
                    .frame(width: 180, height: 180)
                    .overlay(
                        Image("premiumbackground")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(8)
                    )
                    .shadow(color: AppTheme.vibrantGreen.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Text("Nutria PREMIUM")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Pour ceux qui veulent le meilleur")
                    .font(.body)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    showFeaturesSheet.toggle()
                }) {
                    Text("Voir les fonctionnalités débloquées")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppTheme.accent)
                        .underline()
                        .padding(.top, 4)
                }
                
                // ✅ Sécurité si offerings pas chargées
                if let current = viewModel.offerings?.current {
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
                                    isPurchasing = true
                                    defer { isPurchasing = false }
                                    
                                    if let package = current.availablePackages.first(where: { $0.identifier == "$rc_weekly" }) {
                                        await viewModel.purchase(package: package)
                                    } else {
                                        print("⚠️ Aucun package 'weekly' trouvé.")
                                    }
                                }
                            }
                        )

                        PremiumGradientButton(
                            title: "4,99€ / mois",
                            subtitle: "Moins de 0,17€ par jour pour atteindre tes objectifs",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [AppTheme.primaryBlue, AppTheme.vibrantGreen]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            action: {
                                Task {
                                    isPurchasing = true
                                    defer { isPurchasing = false }

                                    if let package = current.availablePackages.first(where: { $0.identifier == "$rc_monthly" }) {
                                        await viewModel.purchase(package: package)
                                    } else {
                                        print("⚠️ Aucun package 'monthly' trouvé.")
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
                                    isPurchasing = true
                                    defer { isPurchasing = false }

                                    if let package = current.availablePackages.first(where: { $0.identifier == "$rc_annual" }) {
                                        await viewModel.purchase(package: package)
                                    } else {
                                        print("⚠️ Aucun package 'annual' trouvé.")
                                    }
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                } else {
                    ProgressView("Chargement des abonnements...")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    HStack {
                        Link("Confidentialité", destination: URL(string: "https://flofrcd.github.io/politique-confidentialite")!)
                            .foregroundColor(AppTheme.accent)
                            .font(.footnote.weight(.semibold))

                        Spacer()

                        Link("Conditions d'utilisation", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .foregroundColor(AppTheme.accent)
                            .font(.footnote.weight(.semibold))
                    }
                    
                    Text("Abonnement à renouvellement automatique. Annulable à tout moment via les réglages de l’App Store.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
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
            
            // ✅ Overlay de chargement pendant achat
            if isPurchasing {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView("Préparation de l’achat…")
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.7)))
            }
        }
        .task {
            await viewModel.loadProducts()
        }
        .onAppear {
            Task {
                if viewModel.offerings == nil {
                    await viewModel.loadProducts()
                }
            }
        }
        .sheet(isPresented: $showFeaturesSheet) {
            PremiumFeaturesSheet()
        }
        .onChange(of: storeKitManager.currentSubscription) { oldValue, newValue in
            if newValue != .free {
                dismiss()
            }
        }
    }
}


