//
//  UserAuthorizationService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 21.02.25.
//

import Foundation

protocol AccountService {
    func getAccount(authToken: String) async throws -> Account
}

final class AccountServiceImpl: BaseBackendService, AccountService {
    // MARK: - UserAuthorizationService
    func getAccount(authToken: String) async throws -> Account {
        let headers = ["Authorization": "Bearer \(authToken)"]
        do {
            let data = try await httpClient.get(path: "account", headers: headers)
            return try decoder.decode(Account.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
}
