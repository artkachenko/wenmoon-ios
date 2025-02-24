//
//  PriceAlertServiceTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 21.10.24.
//

import XCTest
@testable import WenMoon

class PriceAlertServiceTests: XCTestCase {
    // MARK: - Properties
    var service: PriceAlertService!
    var httpClient: HTTPClientMock!
    var username: String!
    var deviceToken: String!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        httpClient = HTTPClientMock()
        service = PriceAlertServiceImpl(httpClient: httpClient)
        username = "test-username"
        deviceToken = "test-device-token"
    }
    
    override func tearDown() {
        service = nil
        httpClient = nil
        username = nil
        deviceToken = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Get Price Alerts
    func testGetPriceAlerts_success() async throws {
        // Setup
        let response = PriceAlertFactoryMock.makePriceAlerts()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let priceAlerts = try await service.getPriceAlerts(username: username, deviceToken: deviceToken)
        
        // Assertions
        assertPriceAlertsEqual(priceAlerts, response)
    }
    
    func testGetPriceAlerts_emptyResponse() async throws {
        // Setup
        let response = [PriceAlert]()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let priceAlerts = try await service.getPriceAlerts(username: username, deviceToken: deviceToken)
        
        // Assertions
        XCTAssertTrue(priceAlerts.isEmpty)
    }
    
    func testGetPriceAlerts_decodingError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeFailedToDecodeResponseError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getPriceAlerts(username: self!.username, deviceToken: self!.deviceToken)
            },
            expectedError: error
        )
    }
    
    // Set Price Alert
    func testSetPriceAlert_success() async throws {
        // Setup
        let response = PriceAlertFactoryMock.makePriceAlert()
        httpClient.postResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let priceAlert = try await service.createPriceAlert(
            PriceAlertFactoryMock.makePriceAlert(),
            username: username,
            deviceToken: deviceToken
        )
        
        // Assertions
        assertPriceAlertsEqual([priceAlert], [response])
    }
    
    func testSetPriceAlert_encodingError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeFailedToEncodeBodyError()
        httpClient.postResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.createPriceAlert(
                    PriceAlertFactoryMock.makePriceAlert(),
                    username: self!.username,
                    deviceToken: self!.deviceToken
                )
            },
            expectedError: error
        )
    }
    
    // Delete Price Alert
    func testDeletePriceAlert_success() async throws {
        // Setup
        let response = PriceAlertFactoryMock.makePriceAlert()
        httpClient.deleteResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let priceAlert = try await service.deletePriceAlert(
            PriceAlertFactoryMock.makePriceAlert(),
            username: username,
            deviceToken: deviceToken
        )
        
        // Assertions
        assertPriceAlertsEqual([priceAlert], [response])
    }
    
    func testDeletePriceAlert_unknownError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeUnknownError()
        httpClient.deleteResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.deletePriceAlert(
                    PriceAlertFactoryMock.makePriceAlert(),
                    username: self!.username,
                    deviceToken: self!.deviceToken
                )
            },
            expectedError: error
        )
    }
}
