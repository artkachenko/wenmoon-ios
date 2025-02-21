//
//  AppLaunchManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 20.02.25.
//

import Foundation

// MARK: - AppLaunchManager
protocol AppLaunchManager {
    var isFirstLaunch: Bool { get }
    func reset()
}

// MARK: - AppLaunchManagerImpl
final class AppLaunchManagerImpl: AppLaunchManager {
    private let manager: AppLaunchManager
    
    var isFirstLaunch: Bool {
        manager.isFirstLaunch
    }
    
    init(manager: AppLaunchManager = AppLaunchManagerSingleton.shared) {
        self.manager = manager
    }
    
    func reset() {
        manager.reset()
    }
}

// MARK: - AppLaunchManagerSingleton
final class AppLaunchManagerSingleton: AppLaunchManager {
    static let shared = AppLaunchManagerSingleton()
    
    private let userDefaultsManager: UserDefaultsManager
    private(set) var isFirstLaunch: Bool
    
    private init() {
        userDefaultsManager = UserDefaultsManagerImpl()
        let isFirstLaunch = (try? userDefaultsManager.getObject(forKey: .isFirstLaunch, objectType: Bool.self)) ?? true
        self.isFirstLaunch = isFirstLaunch
        if isFirstLaunch {
            try? userDefaultsManager.setObject(false, forKey: .isFirstLaunch)
        }
    }
    
    func reset() {
        userDefaultsManager.removeObject(forKey: .isFirstLaunch)
        isFirstLaunch = true
    }
}
