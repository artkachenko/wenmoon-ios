//
//  SwiftDataError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 11.10.24.
//

import Foundation

enum SwiftDataError: DescriptiveError {
    case failedToFetchModels
    case failedToSaveModel
    
    var errorDescription: String {
        switch self {
        case .failedToFetchModels:
            return "Failed to fetch models"
        case .failedToSaveModel:
            return "Failed to save model"
        }
    }
}
