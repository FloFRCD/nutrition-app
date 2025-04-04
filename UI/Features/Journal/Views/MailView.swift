//
//  MailView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 04/04/2025.
//

import Foundation
import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true)
        }
    }
}
