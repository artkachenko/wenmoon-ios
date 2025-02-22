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
    var userDefaultsManager: UserDefaultsManagerMock!
    
    var deviceToken: String!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        priceAlertService = PriceAlertServiceMock()
        userDefaultsManager = UserDefaultsManagerMock()
        
        viewModel = PriceAlertsViewModel(
            coin: CoinData(),
            priceAlertService: priceAlertService,
            userDefaultsManager: userDefaultsManager
        )
        
        deviceToken = "expectedDeviceToken"
    }
    
    override func tearDown() {
        viewModel = nil
        priceAlertService = nil
        userDefaultsManager = nil
        deviceToken = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testCreatePriceAlert_success() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        priceAlertService.createPriceAlertResult = .success(priceAlert)
        
        // Action
        await viewModel.createPriceAlert(for: AccountFactoryMock.makeAccount(), targetPrice: 70_000)
        
        // Assertions
        assertCoinHasAlert(viewModel.coin, priceAlert)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testCreatePriceAlert_encodingError() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        
        let error = ErrorFactoryMock.makeFailedToEncodeBodyError()
        priceAlertService.createPriceAlertResult = .failure(error)
        
        // Action
        await viewModel.createPriceAlert(for: AccountFactoryMock.makeAccount(), targetPrice: 70_000)
        
        // Assertions
        assertCoinHasNoAlert(coin)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testDeletePriceAlert_success() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        coin.priceAlerts.append(priceAlert)
        
        priceAlertService.deletePriceAlertResult = .success(priceAlert)
        
        // Action
        await viewModel.deletePriceAlert(priceAlert, for: AccountFactoryMock.makeAccount())
        
        // Assertions
        assertCoinHasNoAlert(viewModel.coin)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testDeletePriceAlert_apiError() async {
        // Setup
        userDefaultsManager.getObjectReturnValue = [.deviceToken: deviceToken!]
        
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coin = coin
        
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        coin.priceAlerts.append(priceAlert)
        
        let error = ErrorFactoryMock.makeAPIError()
        priceAlertService.deletePriceAlertResult = .failure(error)
        
        // Action
        await viewModel.deletePriceAlert(priceAlert, for: AccountFactoryMock.makeAccount())
        
        // Assertions
        assertCoinHasAlert(viewModel.coin, priceAlert)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testShouldDisableCreateButton() {
        // Setup
        let coin = CoinData()
        let priceAlerts = PriceAlertFactoryMock.makePriceAlerts()
        coin.priceAlerts = priceAlerts
        viewModel.coin = coin
        
        // Assertions
        XCTAssertTrue(viewModel.shouldDisableCreateButton(targetPrice: nil))
        XCTAssertTrue(viewModel.shouldDisableCreateButton(targetPrice: .zero))
        XCTAssertTrue(viewModel.shouldDisableCreateButton(targetPrice: priceAlerts.first!.targetPrice))
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
