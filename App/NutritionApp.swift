//
//  NutritionApp.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//
import SwiftUI

@main
struct NutritionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var localDataManager = LocalDataManager.shared
    @StateObject private var storeKitManager = StoreKitManager.shared
    @StateObject private var nutritionService = NutritionService.shared
    
    init() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.clear]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().tintColor = UIColor.black
        }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(localDataManager)
                    .environmentObject(storeKitManager)
                    .environmentObject(nutritionService)
            }
            .tint(.black)
        }
    }
}
