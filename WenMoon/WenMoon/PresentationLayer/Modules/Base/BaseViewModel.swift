//
//  BaseViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 20.06.23.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {

    // MARK: - Properties

    @Published var errorMessage: String?
    @Published var isLoading = false

    private(set) var persistenceManager: PersistenceManager
    private(set) var userDefaultsManager: UserDefaultsManager

    var cancellables = Set<AnyCancellable>()

    var deviceToken: String? {
        userDefaultsManager.getObject(forKey: "deviceToken", objectType: String.self)
    }

    // MARK: - Initializers

    convenience init() {
        self.init(persistenceManager: PersistenceManagerImpl(), userDefaultsManager: UserDefaultsManagerImpl())
    }

    init(persistenceManager: PersistenceManager, userDefaultsManager: UserDefaultsManager) {
        self.persistenceManager = persistenceManager
        self.userDefaultsManager = userDefaultsManager

        persistenceManager.errorPublisher.sink { [weak self] error in
            self?.errorMessage = error.errorDescription
        }
        .store(in: &cancellables)

        userDefaultsManager.errorPublisher.sink { [weak self] error in
            self?.errorMessage = error.errorDescription
        }
        .store(in: &cancellables)
    }
}
