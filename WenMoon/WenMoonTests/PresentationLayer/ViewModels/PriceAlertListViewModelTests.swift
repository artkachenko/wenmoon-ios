//
//  PriceAlertListViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
import CoreData
import Combine
@testable import WenMoon

class PriceAlertListViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: PriceAlertListViewModel!
    var context: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "WenMoon")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (_, error) in
            if let error = error {
                XCTFail("Failed to create in-memory persistent store: \(error.localizedDescription)")
            }
        }

        context = container.newBackgroundContext()
        viewModel = PriceAlertListViewModel(context: context)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        context = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchPriceAlerts() {
        let coins = Coin.Page.first.mock
        coins.forEach { _ = PriceAlert(coin: $0, context: context) }
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save entity: \(error.localizedDescription)")
        }

        let expectation = XCTestExpectation(description: "Fetch saved price alerts")
        var receivedEntities = [AnyObject]()
        viewModel.$priceAlerts
            .dropFirst()
            .sink { priceAlerts in
                receivedEntities = priceAlerts
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPriceAlerts()

        wait(for: [expectation], timeout: 1)

        XCTAssertFalse(receivedEntities.isEmpty)
        XCTAssertEqual(receivedEntities.count, 2)
        XCTAssertEqual(receivedEntities.first?.id, coins.first?.id)
        XCTAssertEqual(receivedEntities.first?.symbol, coins.first?.symbol)
        XCTAssertEqual(receivedEntities.first?.name, coins.first?.name)
        XCTAssertEqual(receivedEntities.first?.image, coins.first?.image)
        XCTAssertEqual(receivedEntities.last?.id, coins.last?.id)
        XCTAssertEqual(receivedEntities.last?.symbol, coins.last?.symbol)
        XCTAssertEqual(receivedEntities.last?.name, coins.last?.name)
        XCTAssertEqual(receivedEntities.last?.image, coins.last?.image)

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showErrorAlert)
    }

    func testSavePriceAlert() {
        let coin = Coin.mock
        viewModel.savePriceAlert(coin)

        let expectation = XCTestExpectation(description: "Save price alert")
        var receivedEntities = [AnyObject]()
        viewModel.$priceAlerts
            .dropFirst()
            .sink { priceAlerts in
                receivedEntities = priceAlerts
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPriceAlerts()

        wait(for: [expectation], timeout: 1)

        XCTAssertFalse(receivedEntities.isEmpty)
        XCTAssertEqual(receivedEntities.count, 1)
        XCTAssertEqual(receivedEntities.first?.id, coin.id)
        XCTAssertEqual(receivedEntities.first?.symbol, coin.symbol)
        XCTAssertEqual(receivedEntities.first?.name, coin.name)
        XCTAssertEqual(receivedEntities.first?.image, coin.image)

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showErrorAlert)
    }


    func testDeletePriceAlert() {
        let coin = Coin.mock
        let priceAlert = PriceAlert(coin: coin, context: context)
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save entity: \(error.localizedDescription)")
        }

        XCTAssertNotNil(priceAlert.objectID.isTemporaryID)

        viewModel.delete(priceAlert)

        let expectation = XCTestExpectation(description: "Delete price alert")
        viewModel.$priceAlerts
            .dropFirst()
            .sink { priceAlerts in
                XCTAssert(priceAlerts.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPriceAlerts()

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showErrorAlert)
    }

    func testErrorConfiguration() {
        let nsError = NSError(domain: "com.test.error", code: 123)
        let error: PersistenceError = .failedToSaveEntity(error: nsError)

        viewModel.configureError(error)

        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
        XCTAssertTrue(viewModel.showErrorAlert)
    }
}
