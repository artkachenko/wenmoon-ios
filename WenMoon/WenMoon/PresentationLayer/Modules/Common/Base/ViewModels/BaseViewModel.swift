//
//  BaseViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 20.06.23.
//

import UIKit
import SwiftData

class BaseViewModel: ObservableObject {
    // MARK: - Properties
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private(set) var appLaunchProvider: AppLaunchProvider
    private(set) var userDefaultsManager: UserDefaultsManager
    private(set) var swiftDataManager: SwiftDataManager?
    
    private var cacheTimers: [Timer] = []
    
    var isFirstLaunch: Bool {
        appLaunchProvider.isFirstLaunch
    }
    
    var deviceToken: String? {
        try? userDefaultsManager.getObject(forKey: .deviceToken, objectType: String.self)
    }
    
    // MARK: - Initializers
    init(
        appLaunchProvider: AppLaunchProvider? = nil,
        userDefaultsManager: UserDefaultsManager? = nil,
        swiftDataManager: SwiftDataManager? = nil
    ) {
        self.appLaunchProvider = appLaunchProvider ?? DefaultAppLaunchManager()
        self.userDefaultsManager = userDefaultsManager ?? UserDefaultsManagerImpl()
        
        if let swiftDataManager {
            self.swiftDataManager = swiftDataManager
        } else {
            if let modelContainer = try? ModelContainer(for: CoinData.self, Portfolio.self, Transaction.self) {
                self.swiftDataManager = SwiftDataManagerImpl(modelContainer: modelContainer)
            }
        }
    }
    
    deinit {
        for timer in cacheTimers {
            timer.invalidate()
        }
    }
    
    // MARK: - Image Loading
    @MainActor
    func loadImage(from url: URL) async -> Data? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            setErrorMessage("Error downloading image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Cache Handling
    func startCacheTimer(interval: TimeInterval = 60, completion: @escaping (() -> Void)) {
        let newCacheTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            completion()
        }
        cacheTimers.append(newCacheTimer)
    }
    
    // MARK: - SwiftData
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) -> [T] {
        do {
            return try swiftDataManager?.fetch(descriptor) ?? []
        } catch {
            setError(error)
            return []
        }
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        do {
            try swiftDataManager?.insert(model)
        } catch {
            setError(error)
        }
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        do {
            try swiftDataManager?.delete(model)
        } catch {
            setError(error)
        }
    }
    
    func save() {
        do {
            try swiftDataManager?.save()
        } catch {
            setError(error)
        }
    }
    
    // MARK: - Error
    func setError(_ error: Error) {
        if let descriptiveError = error as? DescriptiveError {
            errorMessage = descriptiveError.errorDescription
        } else {
            errorMessage = "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    
    func setErrorMessage(_ message: String) {
        errorMessage = message
    }
    
    // MARK: - Feeback Generator
    func triggerImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
