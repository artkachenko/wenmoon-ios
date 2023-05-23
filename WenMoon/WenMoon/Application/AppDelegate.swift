//
//  AppDelegate.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    private var userDefaultsManager: UserDefaultsManager!
    private let deviceTokenKey = "DEVICE_TOKEN_KEY"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        userDefaultsManager = UserDefaultsManagerImpl()
        registerForPushNotifications()
        return true
    }

    func resetBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = .zero
    }

    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        guard userDefaultsManager.getObject(forKey: deviceTokenKey,
                                            objectType: String.self) == nil else { return }
        userDefaultsManager.setObject(token, forKey: deviceTokenKey)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification in foreground: \(notification)")
        completionHandler([.banner, .badge, .sound])
    }

    // Handle notification when app is in background or not running
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification while app was not running: \(response)")
        completionHandler()
    }
}
