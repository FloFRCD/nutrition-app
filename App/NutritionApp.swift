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
        // MARK: – Firebase init & Auth
        FirebaseApp.configure()

        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        
        print("📦 Bundle ID détecté: \(Bundle.main.bundleIdentifier ?? "nil")")

        Auth.auth().signInAnonymously { result, error in
            if let err = error as NSError? {
                print("❌ Firebase Auth error:", err)
                print("📋 Code: \(err.code), Domain: \(err.domain), Description: \(err.localizedDescription)")
            } else {
                print("✅ Firebase Auth succeeded, uid:", result?.user.uid ?? "–")
            }
        }

        Auth.auth().signInAnonymously { result, error in
            if let err = error {
                print("❌ Firebase Auth error:", err.localizedDescription)
            } else {
                print("✅ Firebase Auth succeeded, uid:", result?.user.uid ?? "–")
            }
        }

        // MARK: – UINavigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes      = [.foregroundColor: UIColor.clear]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.clear]
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor            = .black

        // MARK: – RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_eUkrIamUmldMUFfhqIGDCEQOGvk")
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showSplash {
                    AnimatedSplashView(isActive: $showSplash)
                } else {
                    ContentView()
                        .environmentObject(localDataManager)
                        .environmentObject(storeKitManager)
                        .environmentObject(nutritionService)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            .tint(.black)
            .onAppear {
                Task {
                    await storeKitManager.checkActiveSubscription()
                    await storeKitManager.loadProducts()
                }
            }
        }
    }
}




