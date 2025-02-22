//
//  String+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 10.02.25.
//

import Foundation

extension String {
    var htmlStripped: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
