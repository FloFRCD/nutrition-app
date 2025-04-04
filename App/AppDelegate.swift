//
//  AppDelegate.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI
import UIKit


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupAppearance()
        setupNotifications()
        return true
    }

    // 💥 Ajoute cette méthode pour bloquer l'orientation
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func setupAppearance() {
        // Configuration du style de l'application
    }

    private func setupNotifications() {
        // Configuration des notifications
    }
}




class OrientationLockedViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
}

