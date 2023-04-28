//
//  PersistenceError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

enum PersistenceError: LocalizedError {
    case failedToLoadPersistentStore(error: Error)
    case failedToFetchEntities(error: Error)
    case failedToSaveEntity(error: Error)

    var errorDescription: String? {
        switch self {
        case .failedToLoadPersistentStore(let error):
            return "Failed to load persistent store: \(error.localizedDescription)"
        case .failedToFetchEntities(let error):
            return "Failed to fetch entities: \(error.localizedDescription)"
        case .failedToSaveEntity(let error):
            return "Failed to save entity: \(error.localizedDescription)"
        }
    }
}
