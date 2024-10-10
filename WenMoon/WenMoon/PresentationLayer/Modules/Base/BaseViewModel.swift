//
//  BaseViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 20.06.23.
//

import Foundation

class BaseViewModel: ObservableObject {

    // MARK: - Properties

    @Published var errorMessage: String?
    @Published var isLoading = false

    private(set) var persistenceManager: PersistenceManager
    private(set) var userDefaultsManager: UserDefaultsManager

    var deviceToken: String? {
        try? userDefaultsManager.getObject(forKey: "deviceToken", objectType: String.self)
    }

    // MARK: - Initializers

    convenience init() {
        self.init(persistenceManager: PersistenceManagerImpl(), userDefaultsManager: UserDefaultsManagerImpl())
    }

    init(persistenceManager: PersistenceManager, userDefaultsManager: UserDefaultsManager) {
        self.persistenceManager = persistenceManager
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Methods

    func saveChanges() {
        do {
            try persistenceManager.save()
            objectWillChange.send()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadImage(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
