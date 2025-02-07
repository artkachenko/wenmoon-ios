//
//  UserDefaultsManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

protocol UserDefaultsManager {
    func setObject<T: Encodable>(_ object: T, forKey key: UserDefaultsKey) throws
    func getObject<T: Decodable>(forKey key: UserDefaultsKey, objectType: T.Type) throws -> T?
    func removeObject(forKey key: String)
}

final class UserDefaultsManagerImpl: UserDefaultsManager {
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    
    // MARK: - UserDefaultsManager
    func setObject<T: Encodable>(_ object: T, forKey key: UserDefaultsKey) throws {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key.value)
        } catch {
            throw UserDefaultsError.failedToEncodeObject
        }
    }
    
    func getObject<T: Decodable>(forKey key: UserDefaultsKey, objectType: T.Type) throws -> T? {
        guard let data = userDefaults.data(forKey: key.value) else {
            return nil
        }
        do {
            let object = try JSONDecoder().decode(objectType, from: data)
            return object
        } catch {
            throw UserDefaultsError.failedToDecodeObject
        }
    }
    
    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

enum UserDefaultsKey: Hashable {
    case isFirstLaunch
    case deviceToken
    case sortOption
    case coinsOrder
    case setting(ofType: Setting.SettingType)
    
    var value: String {
        switch self {
        case .isFirstLaunch:
            return "isFirstLaunch"
        case .deviceToken:
            return "deviceToken"
        case .sortOption:
            return "sortOption"
        case .coinsOrder:
            return "coinsOrder"
        case .setting(let type):
            return "setting_\(type)"
        }
    }
}
