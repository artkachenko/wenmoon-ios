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
    
    var isFirstLaunch: Bool {
        appLaunchProvider.isFirstLaunch
    }
    
    var deviceToken: String? {
        let deviceToken = try? userDefaultsManager.getObject(forKey: .deviceToken, objectType: String.self)
        return deviceToken
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
                let swiftDataManager = SwiftDataManagerImpl(modelContainer: modelContainer)
                self.swiftDataManager = swiftDataManager
            }
        }
    }
    
    // MARK: - Internal Methods
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
    
    @MainActor
    func loadImage(from url: URL) async -> Data? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            errorMessage = "Error downloading image: \(error.localizedDescription)"
            return nil
        }
    }
    
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
    
    func triggerImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
