//
//  PersistenceManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import CoreData

struct PersistenceManager {
    static let shared = PersistenceManager()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WenMoon")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let nsError = error as? NSError {
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
