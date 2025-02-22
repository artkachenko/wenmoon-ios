//
//  DescriptiveError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 11.10.24.
//

import Foundation

protocol DescriptiveError: Error {
    var errorDescription: String { get }
}
