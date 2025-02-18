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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localDataManager)
                .environmentObject(storeKitManager)
        }
    }
}
