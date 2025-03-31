//
//  ScanView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ScannerCardView: View {
    var onScanTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // En-tête similaire à la section repas
            HStack {
                Text("Scanner")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Petit badge décoratif avec les couleurs du logo
                Text("Photo")
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.actionButtonGradient)
                    .cornerRadius(20)
                    .foregroundColor(.white)
            }
            
            // Titre et description
            Text("Analyser un plat ou un produit")
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text("Prenez une photo ou scannez un code-barre pour obtenir les infos nutritionnelles")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
                .padding(.top, 4)
            
            // Bouton
            HStack {
                Spacer()
                Button(action: onScanTap) {
                    Text("Scanner")
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.actionButtonGradient)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .onTapGesture {
            onScanTap()
        }
    }
}

// Vue de scan complète
struct ScanView: View {
    @State private var isCameraActive = false
    @State private var scanMode: ScanMode = .photo
    
    enum ScanMode {
        case photo, barcode
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Sélecteur de mode (photo ou code-barre)
            Picker("Mode de scan", selection: $scanMode) {
                Text("Photo").tag(ScanMode.photo)
                Text("Code-barre").tag(ScanMode.barcode)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Zone de caméra
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.6))
                
                if isCameraActive {
                    // Ici vous intégrerez votre vrai composant de caméra
                    Text("Caméra active")
                        .foregroundColor(.white)
                } else {
                    VStack {
                        Image(systemName: scanMode == .photo ? "camera" : "barcode.viewfinder")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text(scanMode == .photo ? "Prenez une photo de votre plat" : "Scannez le code-barre du produit")
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                }
            }
            .frame(height: 360)
            .padding(.horizontal)
            
            // Bouton de scan
            Button(action: {
                // Ici vous activerez la caméra avec l'API appropriée
                isCameraActive = true
                
                // Simuler un scan après 3 secondes (à remplacer par l'appel API réel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isCameraActive = false
                    // Ici vous traiterez les résultats du scan avec l'API appropriée
                }
            }) {
                Text(scanMode == .photo ? "Prendre une photo" : "Scanner le code-barre")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.6, green: 0.2, blue: 0.9), Color(red: 0.2, green: 0.4, blue: 0.9)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Comment ça marche")
                    .font(.headline)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.9))
                    
                    VStack(alignment: .leading) {
                        Text(scanMode == .photo ? "Prenez une photo claire de votre plat" : "Placez le code-barre dans le cadre")
                            .font(.subheadline)
                    }
                }
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "2.circle.fill")
                        .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.9))
                    
                    VStack(alignment: .leading) {
                        Text("Obtenez instantanément les informations nutritionnelles")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .background(AppTheme.background)
    }
}

