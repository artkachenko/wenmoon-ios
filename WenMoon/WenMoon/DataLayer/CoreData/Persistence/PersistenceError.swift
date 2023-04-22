//
//  PersistenceError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

enum PersistenceError: LocalizedError {
    case failedToFetchEntities(error: Error)
    case failedToSaveEntity(error: Error)
    case failedToDeleteEntity(error: Error)

    var errorDescription: String? {
        switch self {
        case .failedToFetchEntities(let error):
            return "Failed to fetch entities: \(error.localizedDescription)"
        case .failedToSaveEntity(let error):
            return "Failed to save entity: \(error.localizedDescription)"
        case .failedToDeleteEntity(let error):
            return "Failed to delete entity: \(error.localizedDescription)"
        }
    }
}
