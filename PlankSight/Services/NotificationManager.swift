//
//  NotificationManager.swift
//  PlankSight
//
//  Created by Muhammad Rizki on 21/04/26.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Request Permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion(granted)
            }
        }
    }
    
    // MARK: - Schedule Daily Notifications
    func scheduleDailyNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let notificationService = NotificationService.shared
        let streak = notificationService.getCurrentStreak()
        guard !notificationService.isSessionCompletedToday() else { return }

        scheduleNotification(
            title: "Selamat Pagi! 🌅",
            body: notificationService.getMorningMessage(streak: streak),
            hour: 9,
            minute: 0,
            identifier: "morning_reminder"
        )
        scheduleNotification(
            title: "Jangan Lupa Plank! 🔥",
            body: notificationService.getEveningMessage(streak: streak),
            hour: 17,
            minute: 0,
            identifier: "evening_reminder"
        )
    }
    
    // MARK: - Schedule Single Notification
    private func scheduleNotification(
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        identifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        if #available(iOS 16, *) {
            UNUserNotificationCenter.current().getDeliveredNotifications { delivered in
                content.badge = NSNumber(value: delivered.count + 1)
                self.addNotification(identifier: identifier, content: content, trigger: trigger)
            }
        } else {
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            addNotification(identifier: identifier, content: content, trigger: trigger)
        }
    }

    private func addNotification(
        identifier: String,
        content: UNMutableNotificationContent,
        trigger: UNNotificationTrigger
    ) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

