//
//  BarcodeProductView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 29/03/2025.
//

import Foundation
import SwiftUI


struct BarcodeProductView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var selectedUnit: String = "g"
    @State private var isLiquid: Bool = false
    

    let product: OpenFoodFactsProduct
    let mealType: MealType
    let onAdd: (FoodEntry) -> Void

    @State private var quantity: String = "100"

    var body: some View {
        Group { // Le Group ici n'est pas essentiel mais ne nuit pas
            if let productName = product.product.productName, !productName.isEmpty {
                // Si le nom du produit existe et n'est pas vide, afficher les détails
                productDetailsView(productName: productName)
            } else {
                // Sinon, afficher l'écran de données manquantes
                missingDataView()
            }
        }
        // Les modificateurs communs aux deux états (ici seulement le bouton Annuler)
        .toolbar {
             ToolbarItem(placement: .cancellationAction) {
                 Button("Annuler") {
                     dismiss()
                 }
             }
         }
        .onAppear {
            setupInitialUnit()
        }
        // Le titre de navigation est maintenant DANS les vues spécifiques
        // car elles pourraient potentiellement avoir des titres différents.
        // Si le titre doit TOUJOURS être le même, vous pouvez le remettre ici.
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func productDetailsView(productName: String) -> some View {
        Form {
            if let nutriments = product.product.nutriments { // Toujours vérifier qu'on a les données de base

                // Section affichant les valeurs CALCULÉES pour la quantité entrée
                Section {
                    // Utiliser les valeurs de la variable calculée `calculatedNutrition`
                    nutritionRow(label: "Calories", value: "\(calculatedNutrition.calories)", unit: "kcal") // .calories est déjà un Int
                    nutritionRow(label: "Protéines", value: String(format: "%.1f", calculatedNutrition.proteins), unit: "g")
                    nutritionRow(label: "Glucides", value: String(format: "%.1f", calculatedNutrition.carbs), unit: "g")
                    nutritionRow(label: "Lipides", value: String(format: "%.1f", calculatedNutrition.fats), unit: "g")
                    nutritionRow(label: "Fibres", value: String(format: "%.1f", calculatedNutrition.fiber), unit: "g")

                } header: {
                    // L'en-tête affiche maintenant la quantité et l'unité entrées par l'utilisateur
                    Text("VALEURS NUTRITIONNELLES (pour \(quantity) \(selectedUnit))")
                }

                // SECTION QUANTITÉ (reste inchangée)
                quantitySection()

                // BOUTON AJOUTER (reste inchangé)
                addButonSection()

            } else {
                // Section si aucune donnée nutritionnelle de base n'est disponible (reste inchangée)
                Section {
                    Text("Aucune information nutritionnelle disponible pour ce produit.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Détails du produit") // Titre spécifique à cette vue
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Toolbar spécifique au clavier pour cette vue
            ToolbarItem(placement: .keyboard) {
                Button("Terminé") {
                    hideKeyboard()
                }
                .frame(maxWidth: .infinity, alignment: .trailing) // Aligner à droite
            }
        }
    }

    @ViewBuilder
    private func quantitySection() -> some View {
        Section(header: Text("QUANTITÉ")) {
            HStack {
                Text("Quantité")
                Spacer()
                TextField("100", text: $quantity)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80) // Augmenter un peu la largeur si besoin

                // Picker d'unité
                Picker("", selection: $selectedUnit) {
                    Text("g").tag("g")
                    Text("ml").tag("ml")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 90) // Ajuster si besoin
            }
        }
    }

    @ViewBuilder
    private func addButonSection() -> some View {
        Section {
             Button {
                 addToJournal()
             } label: {
                 // Utiliser un label pour que le frame s'applique correctement au contenu interne
                 Text("Ajouter au journal")
                     .frame(maxWidth: .infinity) // Étendre le Text pour centrer
                     .padding() // Ajouter le padding au Text
                     .background(Color.blue) // Mettre le fond sur le Text paddé
                     .foregroundColor(.white) // Couleur du texte
                     .cornerRadius(10) // Coins arrondis
             }
             // Appliquer listRowInsets pour supprimer l'indentation par défaut du bouton dans la section
             .listRowInsets(EdgeInsets())
             // Centrer le bouton horizontalement (moins nécessaire avec maxWidth: .infinity sur le Text)
             .frame(maxWidth: .infinity, alignment: .center)
             // Supprimer le style de bouton par défaut pour appliquer notre fond/padding
             .buttonStyle(PlainButtonStyle())
         }
    }


    @ViewBuilder
    private func missingDataView() -> some View {
        VStack(spacing: 20) {
            Text("Données du produit incomplètes")
                .font(.headline)

            Text("Code-barres: \(product.code)")

            VStack(alignment: .leading) {
                Text("Données reçues (débogage):")
                    .font(.subheadline)
                Text("Nom: \(product.product.productName ?? "Aucun")")

                if let nutriments = product.product.nutriments {
                    let caloriesText = "\(nutriments.energyKcal100g ?? 0)" // Afficher pour 100g
                    Text("Calories (pour 100g/ml): \(caloriesText)")
                    // Vous pourriez afficher d'autres nutriments ici si disponibles
                } else {
                    Text("Nutriments: Aucun")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            Button("Retour") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Erreur Produit") // Titre différent pour cet état
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func nutritionRow(label: String, value: String, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value) \(unit)")
                .foregroundColor(.secondary)
        }
    }
    
    private func setupInitialUnit() {
            // Détection de liquide basée sur le nom du produit
            let productName = product.product.productName?.lowercased() ?? ""
            isLiquid = productName.contains("eau") ||
                       productName.contains("boisson") ||
                       productName.contains("jus") ||
                       productName.contains("lait") ||
                       productName.contains("soda") || // Ajouter d'autres termes si nécessaire
                       productName.contains("drink")

            // Si c'est un liquide, utiliser ml par défaut
            if isLiquid {
                selectedUnit = "ml"
            } else {
                selectedUnit = "g" // Assurer que c'est 'g' sinon
            }
            // Mettre à jour l'unité dans l'en-tête (si la vue est déjà apparue)
            // Cela sera géré par le redraw de SwiftUI via @State
        }
    
    private func addToJournal() {
        guard let nutriments = product.product.nutriments,
              let quantityValue = Double(quantity) else {
            return
        }
        
        // Convertir l'unité sélectionnée en ServingUnit
        let servingUnit: ServingUnit = selectedUnit == "ml" ? .milliliter : .gram
        
        // Créer un objet Food
        let food = Food(
            id: UUID(),
            name: product.product.productName ?? "Produit scanné",
            calories: Int(nutriments.energyKcal100g ?? 0),
            proteins: nutriments.proteins100g ?? 0,
            carbs: nutriments.carbohydrates100g ?? 0,
            fats: nutriments.fat100g ?? 0,
            fiber: nutriments.fiber100g ?? 0,
            servingSize: 100, // Valeurs nutritionnelles pour 100g/ml
            servingUnit: servingUnit,
            image: nil
        )
        
        // Créer l'entrée pour le journal avec la quantité correcte
        let entry = FoodEntry(
            id: UUID(),
            food: food,
            quantity: quantityValue, // Division par 100 car les valeurs sont pour 100g/ml
            date: Date(),
            mealType: mealType,
            source: .barcode
        )
        
        // Appeler la closure pour ajouter au journal
        journalViewModel.addFoodEntry(entry)
        
        NotificationCenter.default.post(name: .dismissAllSheets, object: nil)
    }
    
    private var calculatedNutrition: (calories: Int, proteins: Double, carbs: Double, fats: Double, fiber: Double) {
        guard let nutriments = product.product.nutriments,
              let quantityValue = Double(quantity) else {
            return (0, 0, 0, 0, 0)
        }
        
        let ratio = quantityValue / 100.0
        
        return (
            Int((nutriments.energyKcal100g ?? 0) * ratio),
            (nutriments.proteins100g ?? 0) * ratio,
            (nutriments.carbohydrates100g ?? 0) * ratio,
            (nutriments.fat100g ?? 0) * ratio,
            (nutriments.fiber100g ?? 0) * ratio
        )
    }
    
    private func hideKeyboard() {
           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
       }
}
