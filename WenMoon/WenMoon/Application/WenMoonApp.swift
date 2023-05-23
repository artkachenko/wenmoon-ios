//
//  WenMoonApp.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI
import UserNotifications

@main
struct WenMoonApp: App {

    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            PriceAlertListView()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                appDelegate.resetBadgeNumber()
            }
        }
    }
}
