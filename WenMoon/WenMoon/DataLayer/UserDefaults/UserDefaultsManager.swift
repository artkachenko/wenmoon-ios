//
//  UserDefaultsManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation
import Combine

protocol UserDefaultsManager {
    var errorPublisher: AnyPublisher<UserDefaultsError, Never> { get }

    func setObject<T: Encodable>(_ object: T, forKey key: String)
    func getObject<T: Decodable>(forKey key: String, objectType: T.Type) -> T?
    func removeObject(forKey key: String)
}

final class UserDefaultsManagerImpl: UserDefaultsManager {

    private let userDefaults = UserDefaults.standard
    private let errorSubject = PassthroughSubject<UserDefaultsError, Never>()

    var errorPublisher: AnyPublisher<UserDefaultsError, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    func setObject<T: Encodable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key)
        } catch {
            errorSubject.send(.failedToEncodeObject(error: error))
        }
    }

    func getObject<T: Decodable>(forKey key: String, objectType: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        do {
            let object = try JSONDecoder().decode(objectType, from: data)
            return object
        } catch {
            errorSubject.send(.failedToDecodeObject(error: error))
            return nil
        }
    }

    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
