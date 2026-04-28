//
//  AppDelegate.swift
//  PlankSight
//
//  Created by Muhammad Rizki on 21/04/26.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    // Controlled by CameraView — portrait everywhere except during camera session
    static var orientationLock: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permission
        NotificationManager.shared.requestNotificationPermission { granted in
            if granted {
                // Schedule initial notifications
                NotificationManager.shared.scheduleDailyNotifications()
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Check and reset streak if needed when app becomes active
        NotificationService.shared.checkAndResetStreak()
        
        // Reschedule notifications
        NotificationManager.shared.scheduleDailyNotifications()
    }
}

// MARK: - UNUserNotificationCenter Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let _ = notification.request.content.userInfo
        
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap - navigate to camera
        print("Notification tapped - User will see home screen")
        completionHandler()
    }
}
