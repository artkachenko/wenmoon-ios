//
//  PersistenceManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import CoreData
import Combine

protocol PersistenceManager {
    var context: NSManagedObjectContext { get }
    var errorPublisher: AnyPublisher<PersistenceError, Never> { get }
    
    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) -> [T]?
    func save()
    func delete(_ object: NSManagedObject)
}

final class PersistenceManagerImpl: PersistenceManager {

    private let container: NSPersistentContainer
    private let errorSubject = PassthroughSubject<PersistenceError, Never>()

    var context: NSManagedObjectContext {
        container.viewContext
    }

    var errorPublisher: AnyPublisher<PersistenceError, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    init() {
        container = NSPersistentContainer(name: "WenMoon")
        container.loadPersistentStores(completionHandler: { [weak self] (_, error) in
            if let nsError = error as? NSError {
                self?.errorSubject.send(.failedToLoadPersistentStore(error: nsError))
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) -> [T]? {
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            errorSubject.send(.failedToFetchEntities(error: error as NSError))
            return nil
        }
    }

    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                errorSubject.send(.failedToSaveEntity(error: error as NSError))
            }
        }
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
        save()
    }
}
