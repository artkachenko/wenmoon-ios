//
//  PriceAlertsViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 02.12.24.
//

import XCTest
@testable import WenMoon

class PriceAlertsViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: PriceAlertsViewModel!
    
    var priceAlertService: PriceAlertServiceMock!
    var firebaseAuthService: FirebaseAuthServiceMock!
    var userDefaultsManager: UserDefaultsManagerMock!
    
    var deviceToken: String!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        priceAlertService = PriceAlertServiceMock()
        firebaseAuthService = FirebaseAuthServiceMock()
        userDefaultsManager = UserDefaultsManagerMock()
        
        viewModel = PriceAlertsViewModel(
            priceAlertService: priceAlertService,
            firebaseAuthService: firebaseAuthService,
            userDefaultsManager: userDefaultsManager
        )
        
        firebaseAuthService.idTokenResult = .success("test-id-token")
        deviceToken = "test-device-token"
    }
    
    override func tearDown() {
        viewModel = nil
        priceAlertService = nil
        firebaseAuthService = nil
        userDefaultsManager = nil
        deviceToken = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Fetch Price Alerts
    func testFetchPriceAlerts_success() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let priceAlerts = PriceAlertFactoryMock.makePriceAlerts()
        priceAlertService.getPriceAlertsResult = .success(priceAlerts)
        
        // Action
        let receivedPriceAlerts = await viewModel.fetchPriceAlerts()
        
        // Assertions
        XCTAssertEqual(receivedPriceAlerts, priceAlerts)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchPriceAlerts_emptyResult() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        priceAlertService.getPriceAlertsResult = .success([])
        
        // Action
        let receivedPriceAlerts = await viewModel.fetchPriceAlerts()
        
        // Assertions
        XCTAssertTrue(receivedPriceAlerts.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchPriceAlerts_failedToFetchFirebaseToken() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let error: AuthError = .failedToFetchFirebaseToken
        firebaseAuthService.idTokenResult = .failure(error)
        
        // Action
        _ = await viewModel.fetchPriceAlerts()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testFetchPriceAlerts_invalidEndpoint() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let error = ErrorFactoryMock.makeInvalidEndpointError()
        priceAlertService.getPriceAlertsResult = .failure(error)
        
        // Action
        _ = await viewModel.fetchPriceAlerts()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Create Price Alert
    func testCreatePriceAlert_success() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        priceAlertService.createPriceAlertResult = .success(priceAlert)
        
        // Action
        await viewModel.createPriceAlert(for: coin, targetPrice: 70_000)
        
        // Assertions
        assertCoinHasAlert(coin, priceAlert)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testCreatePriceAlert_encodingError() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        
        let error: APIError = .failedToEncodeBody
        priceAlertService.createPriceAlertResult = .failure(error)
        
        // Action
        await viewModel.createPriceAlert(for: coin, targetPrice: 70_000)
        
        // Assertions
        assertCoinHasNoAlert(coin)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Delete Price Alert
    func testDeletePriceAlert_success() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        coin.priceAlerts.append(priceAlert)
        
        priceAlertService.deletePriceAlertResult = .success(priceAlert)
        
        // Action
        await viewModel.deletePriceAlert(priceAlert, for: coin)
        
        // Assertions
        assertCoinHasNoAlert(coin)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testDeletePriceAlert_apiError() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        coin.priceAlerts.append(priceAlert)
        
        let error = ErrorFactoryMock.makeAPIError()
        priceAlertService.deletePriceAlertResult = .failure(error)
        
        // Action
        await viewModel.deletePriceAlert(priceAlert, for: coin)
        
        // Assertions
        assertCoinHasAlert(coin, priceAlert)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Misc
    func testShouldDisableCreateButton() {
        // Setup
        let priceAlerts = PriceAlertFactoryMock.makePriceAlerts()
        
        // Assertions
        XCTAssertTrue(viewModel.shouldDisableCreateButton(priceAlerts: priceAlerts, targetPrice: nil))
        XCTAssertTrue(viewModel.shouldDisableCreateButton(priceAlerts: priceAlerts, targetPrice: .zero))
        XCTAssertTrue(viewModel.shouldDisableCreateButton(priceAlerts: priceAlerts, targetPrice: priceAlerts.first!.targetPrice))
        XCTAssertFalse(viewModel.shouldDisableCreateButton(priceAlerts: priceAlerts, targetPrice: 150_000))
    }
    
    func testGetTargetDirection() {
        // Setup
        let price: Double = 60_000
        
        // Assertions
        XCTAssertEqual(viewModel.getTargetDirection(for: 65_000, price: price), .above)
        XCTAssertEqual(viewModel.getTargetDirection(for: 55_000, price: price), .below)
        XCTAssertEqual(viewModel.getTargetDirection(for: 60_000, price: price), .above)
    }
}
