//
//  Comparable+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.11.24.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
