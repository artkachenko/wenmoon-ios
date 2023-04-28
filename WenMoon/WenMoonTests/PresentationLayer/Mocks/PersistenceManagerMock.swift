//
//  PersistenceManagerMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 27.04.23.
//

import CoreData
import Combine
@testable import WenMoon

class PersistenceManagerMock: PersistenceManager {

    var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var errorPublisher: AnyPublisher<PersistenceError, Never> = Empty().eraseToAnyPublisher()

    var fetchMethodCalled = false
    var saveMethodCalled = false
    var deleteMethodCalled = false

    var fetchRequestResult: [NSFetchRequestResult] = []
    var deletedObject: NSManagedObject?
    var persistenceError: PersistenceError?

    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) -> [T]? {
        guard persistenceError == nil else {
            sendError(persistenceError!)
            return nil
        }
        fetchMethodCalled = true
        return fetchRequestResult as? [T]
    }

    func save() {
        guard persistenceError == nil else {
            sendError(persistenceError!)
            return
        }
        saveMethodCalled = true
    }

    func delete(_ object: NSManagedObject) {
        guard persistenceError == nil else {
            sendError(persistenceError!)
            return
        }
        deleteMethodCalled = true
        deletedObject = object
    }

    func sendError(_ error: PersistenceError) {
        errorPublisher = Just(error).eraseToAnyPublisher()
    }
}
