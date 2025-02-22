//
//  AppLaunchManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 20.02.25.
//

import Foundation

// MARK: - AppLaunchProvider
protocol AppLaunchProvider {
    var isFirstLaunch: Bool { get }
    func reset()
}

// MARK: - DefaultAppLaunchManager
final class DefaultAppLaunchManager: AppLaunchProvider {
    private let provider: AppLaunchProvider
    
    var isFirstLaunch: Bool {
        provider.isFirstLaunch
    }
    
    init(provider: AppLaunchProvider = AppLaunchStore.shared) {
        self.provider = provider
    }
    
    func reset() {
        provider.reset()
    }
}

// MARK: - AppLaunchStore (Singleton)
final class AppLaunchStore: AppLaunchProvider {
    static let shared = AppLaunchStore()
    
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
