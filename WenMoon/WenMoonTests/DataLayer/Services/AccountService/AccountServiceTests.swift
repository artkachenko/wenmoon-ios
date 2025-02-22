//
//  AccountServiceTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.02.25.
//

import XCTest
@testable import WenMoon

class AccountServiceTests: XCTestCase {
    // MARK: - Properties
    var service: AccountService!
    var httpClient: HTTPClientMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        httpClient = HTTPClientMock()
        service = AccountServiceImpl(httpClient: httpClient)
    }
    
    override func tearDown() {
        service = nil
        httpClient = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testGetAccount_success() async throws {
        // Setup
        let response = AccountFactoryMock.makeAccount()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let account = try await service.getAccount(authToken: "test-token")
        
        // Assertions
        XCTAssertEqual(account, response)
    }
    
    func testGetAccount_apiError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getAccount(authToken: "test-token")
            },
            expectedError: error
        )
    }
}
