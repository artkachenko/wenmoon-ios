//
//  SwiftDataManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 11.10.24.
//

import Foundation
import SwiftData

protocol SwiftDataManager {
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T]
    func insert<T: PersistentModel>(_ model: T) throws
    func delete<T: PersistentModel>(_ model: T) throws
    func save() throws
}

final class SwiftDataManagerImpl: SwiftDataManager {
    // MARK: - Properties
    private let modelContext: ModelContext
    
    // MARK: - Initializers
    init(modelContainer: ModelContainer) {
        modelContext = ModelContext(modelContainer)
    }
    
    // MARK: - SwiftDataManager
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        do {
            let data = try modelContext.fetch(descriptor)
            return data
        } catch {
            throw SwiftDataError.failedToFetchModels
        }
    }
    
    func insert<T: PersistentModel>(_ model: T) throws {
        modelContext.insert(model)
        try save()
    }
    
    func delete<T: PersistentModel>(_ model: T) throws {
        modelContext.delete(model)
        try save()
    }
    
    func save() throws {
        if modelContext.hasChanges {
            do {
                try modelContext.save()
            } catch {
                throw SwiftDataError.failedToSaveModel
            }
        }
    }
}
