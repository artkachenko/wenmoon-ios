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
            coin: CoinData(),
            priceAlertService: priceAlertService,
            firebaseAuthService: firebaseAuthService,
            userDefaultsManager: userDefaultsManager
        )
        
        deviceToken = "expectedDeviceToken"
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
    func testCreatePriceAlert_success() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        priceAlertService.createPriceAlertResult = .success(priceAlert)
        
        // Action
        await viewModel.createPriceAlert(targetPrice: 70_000)
        
        // Assertions
        assertCoinHasAlert(viewModel.coin, priceAlert)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testCreatePriceAlert_encodingError() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        let error = ErrorFactoryMock.makeFailedToEncodeBodyError()
        priceAlertService.createPriceAlertResult = .failure(error)
        
        // Action
        await viewModel.createPriceAlert(targetPrice: 70_000)
        
        // Assertions
        assertCoinHasNoAlert(coin)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testDeletePriceAlert_success() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        coin.priceAlerts.append(priceAlert)
        priceAlertService.deletePriceAlertResult = .success(priceAlert)
        
        // Action
        await viewModel.deletePriceAlert(priceAlert)
        
        // Assertions
        assertCoinHasNoAlert(viewModel.coin)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testDeletePriceAlert_apiError() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        coin.priceAlerts.append(priceAlert)
        let error = ErrorFactoryMock.makeAPIError()
        priceAlertService.deletePriceAlertResult = .failure(error)
        
        // Action
        await viewModel.deletePriceAlert(priceAlert)
        
        // Assertions
        assertCoinHasAlert(viewModel.coin, priceAlert)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testShouldDisableCreateButton() async {
        // Setup
        let coin = CoinData()
        let priceAlerts = PriceAlertFactoryMock.makePriceAlerts()
        coin.priceAlerts = priceAlerts
        viewModel.coin = coin
        
        // Assertions
        XCTAssert(viewModel.shouldDisableCreateButton(targetPrice: nil))
        XCTAssert(viewModel.shouldDisableCreateButton(targetPrice: .zero))
        XCTAssert(viewModel.shouldDisableCreateButton(targetPrice: priceAlerts.first!.targetPrice))
        XCTAssertFalse(viewModel.shouldDisableCreateButton(targetPrice: 150_000))
    }
    
    func testGetTargetDirection() {
        // Setup
        let coin = CoinData()
        coin.currentPrice = 60_000
        viewModel.coin = coin
        
        // Assertions
        XCTAssertEqual(viewModel.getTargetDirection(for: 65_000), .above)
        XCTAssertEqual(viewModel.getTargetDirection(for: 55_000), .below)
        XCTAssertEqual(viewModel.getTargetDirection(for: 60_000), .above)
    }
}
