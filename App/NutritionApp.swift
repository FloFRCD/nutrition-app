//
//  NutritionApp.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.


import SwiftUI
import RevenueCat
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseAppCheck

@main
struct NutritionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var localDataManager  = LocalDataManager.shared
    @StateObject private var storeKitManager   = StoreKitManager.shared
    @StateObject private var nutritionService  = NutritionService.shared

    @State private var showSplash = true
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())

        Auth.auth().signInAnonymously { result, error in
            if let err = error {
                print("❌ Firebase Auth error:", err.localizedDescription)
            } else {
                print("✅ Firebase Auth succeeded, uid:", result?.user.uid ?? "–")
            }
        }

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_eUkrIamUmldMUFfhqIGDCEQOGvk")

        print("📦 Bundle ID détecté: \(Bundle.main.bundleIdentifier ?? "nil")")
    }


    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showSplash {
                    AnimatedSplashView(isActive: $showSplash)
                        .onAppear {
                            Task {
                                await storeKitManager.loadProducts() // Préchargement ici
                                await storeKitManager.checkActiveSubscription()
                            }
                        }
                } else {
                    ContentView()
                        .environmentObject(localDataManager)
                        .environmentObject(storeKitManager)
                        .environmentObject(nutritionService)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .onAppear {
                            // Double sécurité au cas où le splash aurait échoué
                            Task {
                                await storeKitManager.loadProducts()
                                await storeKitManager.checkActiveSubscription()
                            }
                        }
                }
            }
            .tint(.black)
        }
    }
}
