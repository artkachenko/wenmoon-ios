//
//  View+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 13.02.25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
