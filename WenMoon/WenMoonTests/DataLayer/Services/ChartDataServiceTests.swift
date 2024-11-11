//
//  ChartDataServiceTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.11.24.
//

import XCTest
@testable import WenMoon

class ChartDataServiceTests: XCTestCase {
    // MARK: - Properties
    var service: ChartDataService!
    var httpClient: HTTPClientMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        httpClient = HTTPClientMock()
        service = ChartDataServiceImpl(httpClient: httpClient, baseURL: URL(string: "https://example.com/")!)
    }
    
    override func tearDown() {
        service = nil
        httpClient = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Get Coins
    func testGetChartData_success() async throws {
        // Setup
        let response = ChartDataFactoryMock.makeChartData()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let chartData = try await service.getChartData(for: "")
        
        // Assertions
        assertChartDataEqual(chartData, response)
    }
    
    func testGetCoinsAtPage_apiError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeInvalidParameterError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getChartData(for: "")
            },
            expectedError: error
        )
    }
}
