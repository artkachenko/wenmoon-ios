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
    
    private(set) var firebaseAuthService: FirebaseAuthService
    private(set) var userDefaultsManager: UserDefaultsManager
    private(set) var swiftDataManager: SwiftDataManager?
    
    var userID: String? {
        firebaseAuthService.userID
    }
    
    var deviceToken: String? {
        let deviceToken = try? userDefaultsManager.getObject(forKey: .deviceToken, objectType: String.self)
        return deviceToken
    }
    
    var isFirstLaunch: Bool {
        let isFirstLaunch = (try? userDefaultsManager.getObject(forKey: .isFirstLaunch, objectType: Bool.self)) ?? true
        if isFirstLaunch {
            try? userDefaultsManager.setObject(false, forKey: .isFirstLaunch)
        }
        return isFirstLaunch
    }
    
    // MARK: - Initializers
    init(
        firebaseAuthService: FirebaseAuthService? = nil,
        userDefaultsManager: UserDefaultsManager? = nil,
        swiftDataManager: SwiftDataManager? = nil
    ) {
        self.firebaseAuthService = firebaseAuthService ?? FirebaseAuthServiceImpl()
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
            setErrorMessage(error)
            return []
        }
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        do {
            try swiftDataManager?.insert(model)
        } catch {
            setErrorMessage(error)
        }
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        do {
            try swiftDataManager?.delete(model)
        } catch {
            setErrorMessage(error)
        }
    }
    
    func save() {
        do {
            try swiftDataManager?.save()
        } catch {
            setErrorMessage(error)
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

    func setErrorMessage(_ error: Error) {
        if let descriptiveError = error as? DescriptiveError {
            errorMessage = descriptiveError.errorDescription
        } else {
            errorMessage = "An unknown error occurred: \(error.localizedDescription)"
        }
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
