//
//  PersistenceManagerMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 27.04.23.
//

import SwiftData
@testable import WenMoon

final class SwiftDataManagerMock: SwiftDataManager {
    // MARK: - Properties
    var fetchMethodCalled = false
    var insertMethodCalled = false
    var deleteMethodCalled = false
    var saveMethodCalled = false
    
    var fetchResult: [any PersistentModel] = []
    var insertedModel: (any PersistentModel)!
    var deletedModel: (any PersistentModel)!
    
    var swiftDataError: WenMoon.SwiftDataError!
    
    // MARK: - SwiftDataManager
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        fetchMethodCalled = true
        if let error = swiftDataError {
            throw error
        }
        return fetchResult.compactMap { $0 as? T }
    }
    
    func insert<T: PersistentModel>(_ model: T) throws {
        insertMethodCalled = true
        insertedModel = model
        fetchResult.append(model)
        try save()
    }
    
    func delete<T: PersistentModel>(_ model: T) throws {
        deleteMethodCalled = true
        deletedModel = model
        try save()
    }
    
    func save() throws {
        saveMethodCalled = true
        if let error = swiftDataError {
            throw error
        }
    }
}
