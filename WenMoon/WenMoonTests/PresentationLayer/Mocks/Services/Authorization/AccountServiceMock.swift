//
//  AccountServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.02.25.
//

import XCTest
@testable import WenMoon

class AccountServiceMock: AccountService {
    var getAccountResult: Result<Account, AuthError>!
    var deleteAccountResult: Result<Void, AuthError>!
    
    func getAccount(authToken: String) async throws -> Account {
        switch getAccountResult {
        case .success(let account):
            return account
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getAccountResult not set")
            throw AuthError.failedToFetchAccount
        }
    }
    
    func deleteAccount(authToken: String) async throws {
        switch deleteAccountResult {
        case .success:
            return
        case .failure(let error):
            throw error
        case .none:
            XCTFail("deleteAccountResult not set")
            throw AuthError.failedToDeleteAccount
        }
    }
}
