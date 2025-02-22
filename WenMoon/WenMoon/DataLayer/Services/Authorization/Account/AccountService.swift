//
//  UserAuthorizationService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 21.02.25.
//

import Foundation

protocol AccountService {
    func getAccount(authToken: String) async throws -> Account
    func deleteAccount(authToken: String) async throws
}

final class AccountServiceImpl: BaseBackendService, AccountService {
    // MARK: - AccountService
    func getAccount(authToken: String) async throws -> Account {
        let headers = ["Authorization": "Bearer \(authToken)"]
        do {
            let data = try await httpClient.get(path: "account", headers: headers)
            return try decoder.decode(Account.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func deleteAccount(authToken: String) async throws {
        let headers = ["Authorization": "Bearer \(authToken)"]
        do {
            _ = try await httpClient.delete(path: "account", headers: headers)
        } catch {
            throw mapToAPIError(error)
        }
    }
}
