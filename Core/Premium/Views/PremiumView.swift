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

    
    var body: some View {
        ZStack {
            AppBackgroundDark().ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                
                // Cadre gradient autour de l'image
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
                Text("L’expérience ultime pour ceux qui veulent le meilleur.")
                    .font(.body)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil) // autorise autant de lignes que nécessaire
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                // Boutons d’abonnement
                VStack(spacing: 16) {
                    PremiumGradientButton(
                        title: "1,50€ / semaine",
                        subtitle: "Abonnement flexible, sans engagement",
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [AppTheme.logoPurple, AppTheme.primaryBlue]),
                            startPoint: .leading, endPoint: .trailing
                        ),
                        action: {
                            Task {
                                if let product = viewModel.products.first(where: { $0.id == PremiumProductID.weekly.rawValue }) {
                                    await viewModel.purchase(product: product)
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
                                if let product = viewModel.products.first(where: { $0.id == PremiumProductID.monthly.rawValue }) {
                                    await viewModel.purchase(product: product)
                                }
                            }
                        }

                    )
                    
                    PremiumGradientButton(
                        title: "40€ / an",
                        subtitle: "Économisez 33% (au lieu de 59,88€)",
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [AppTheme.vibrantGreen, AppTheme.lightYellow]),
                            startPoint: .leading, endPoint: .trailing
                        ),
                        action: {
                            Task {
                                if let product = viewModel.products.first(where: { $0.id == PremiumProductID.yearly.rawValue }) {
                                    await viewModel.purchase(product: product)
                                }
                            }
                        }

                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss() // ferme la vue
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
        }
    }
}



#Preview {
    PremiumView()
}
