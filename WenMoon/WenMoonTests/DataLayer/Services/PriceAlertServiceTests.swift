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

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        httpClient = HTTPClientMock()
        service = PriceAlertServiceImpl(httpClient: httpClient, baseURL: URL(string: "https://example.com/")!)
    }

    override func tearDown() {
        service = nil
        httpClient = nil
        super.tearDown()
    }

    // MARK: - Tests
    // Get Price Alerts
    func testGetPriceAlertsSuccess() async throws {
        let response = makePriceAlerts()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))

        let priceAlerts = try await service.getPriceAlerts(deviceToken: "")
        
        XCTAssertFalse(priceAlerts.isEmpty)
        XCTAssertEqual(priceAlerts.count, response.count)

        assertPriceAlert(priceAlerts.first!, response.first!)
        assertPriceAlert(priceAlerts.last!, response.last!)
    }

    func testGetPriceAlertsFailure() async throws {
        let apiError = makeAPIError()
        httpClient.getResponse = .failure(apiError)

        await assertAPIFailure(
            for: { [weak self] in
                try await self?.service.getPriceAlerts(deviceToken: "")
            },
            expectedError: apiError
        )
    }

    // Set Price Alert
    func testSetPriceAlertSuccess() async throws {
        let bitcoin = makeCoinData()
        let response = makeBitcoinPriceAlert()
        httpClient.postResponse = .success(try! httpClient.encoder.encode(response))

        let priceAlert = try await service.setPriceAlert(for: bitcoin, deviceToken: "")
        
        assertPriceAlert(priceAlert, response)
    }

    func testSetPriceAlertFailure() async throws {
        let bitcoin = makeCoinData()
        let apiError = makeAPIError()
        httpClient.postResponse = .failure(apiError)

        await assertAPIFailure(
            for: { [weak self] in
                try await self?.service.setPriceAlert(for: bitcoin, deviceToken: "")
            },
            expectedError: apiError
        )
    }

    // Delete Price Alert
    func testDeletePriceAlertSuccess() async throws {
        let response = makeBitcoinPriceAlert()
        httpClient.deleteResponse = .success(try! httpClient.encoder.encode(response))

        let priceAlert = try await service.deletePriceAlert(for: "1", deviceToken: "")
        
        assertPriceAlert(priceAlert, response)
    }

    func testDeletePriceAlertFailure() async throws {
        let apiError = makeAPIError()
        httpClient.deleteResponse = .failure(apiError)
        
        await assertAPIFailure(
            for: { [weak self] in
                try await self?.service.deletePriceAlert(for: "1", deviceToken: "")
            },
            expectedError: apiError
        )
    }
}
