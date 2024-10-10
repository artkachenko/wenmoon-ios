//
//  PersistenceManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import CoreData

protocol PersistenceManager {
    var context: NSManagedObjectContext { get }

    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T]
    func save() throws
    func delete(_ object: NSManagedObject) throws
}

final class PersistenceManagerImpl: PersistenceManager {

    private let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    init() {
        container = NSPersistentContainer(name: "WenMoon")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let nsError = error as? NSError {
                print("Failed to load persistent store: \(nsError), \(nsError.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        do {
            return try context.fetch(request)
        } catch {
            throw PersistenceError.failedToFetchEntities(error: error as NSError)
        }
    }

    func save() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw PersistenceError.failedToSaveEntity(error: error as NSError)
            }
        }
    }

    func delete(_ object: NSManagedObject) throws {
        context.delete(object)
        try save()
    }
}
