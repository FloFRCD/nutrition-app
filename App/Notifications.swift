//
//  Notifications.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 29/03/2025.
//


import Foundation
import UserNotifications

// Extensions des notifications pour la communication entre les vues
extension Notification.Name {
    /// Notification pour fermer toutes les sheets modales et revenir à la vue principale
    static let dismissAllSheets = Notification.Name("dismissAllSheets")
    
    /// Notification pour mettre à jour le journal alimentaire
    static let refreshFoodJournal = Notification.Name("refreshFoodJournal")
    
    static let hideTabBar = Notification.Name("hideTabBar")
    static let showTabBar = Notification.Name("showTabBar")
    static let weightDataDidChange = Notification.Name("weightDataDidChange")
}


class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission notifications : \(granted)")
        }
    }
    
    func scheduleNotification(title: String, body: String, hour: Int, minute: Int, identifier: String, repeatInterval: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeatInterval)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}


