//
//  AccountFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.02.25.
//

import Foundation
@testable import WenMoon

struct AccountFactoryMock {
    static func makeAccount(id: String = "test-id", username: String = "test-username") -> Account {
        Account(id: id, username: username)
    }
}
