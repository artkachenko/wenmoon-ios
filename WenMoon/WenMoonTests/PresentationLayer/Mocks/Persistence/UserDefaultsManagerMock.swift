//
//  UserDefaultsManagerMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.06.23.
//

import Foundation
@testable import WenMoon

class UserDefaultsManagerMock: UserDefaultsManager {
    // MARK: - Properties
    var setObjectCalled = false
    var getObjectCalled = false
    var removeObjectCalled = false
    
    var getObjectReturnValue: [String: Any] = [:]
    var setObjectValue: [String: Any] = [:]
    
    // MARK: - UserDefaultsManager
    func setObject<T: Encodable>(_ object: T, forKey key: String) {
        setObjectCalled = true
        setObjectValue[key] = object
    }
    
    func getObject<T: Decodable>(forKey key: String, objectType: T.Type) -> T? {
        getObjectCalled = true
        return getObjectReturnValue[key] as? T
    }
    
    func removeObject(forKey key: String) {
        removeObjectCalled = true
    }
}
