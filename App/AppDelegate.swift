//
//  AppDelegate.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 18/02/2025.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }

    private func setupAppearance() {
        // Ton style UI ici
    }

    private func setupNotifications() {
        // Notifications ici (optionnel)
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
