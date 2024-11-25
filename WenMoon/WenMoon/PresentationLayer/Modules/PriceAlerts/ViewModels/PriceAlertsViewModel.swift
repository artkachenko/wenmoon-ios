//
//  PriceAlertsViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 28.11.24.
//

import Foundation

final class PriceAlertsViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var coin: CoinData
    
    @Published private(set) var isCreatingPriceAlert = false
    @Published private(set) var deletingPriceAlertIDs: [String] = []
    
    private let priceAlertService: PriceAlertService
    
    // MARK: - Initializers
    convenience init(coin: CoinData) {
        self.init(
            coin: coin,
            priceAlertService: PriceAlertServiceImpl(),
            firebaseAuthService: FirebaseAuthServiceImpl(),
            userDefaultsManager: UserDefaultsManagerImpl()
        )
    }
    
    init(
        coin: CoinData,
        priceAlertService: PriceAlertService,
        firebaseAuthService: FirebaseAuthService,
        userDefaultsManager: UserDefaultsManager? = nil
    ) {
        self.coin = coin
        self.priceAlertService = priceAlertService
        super.init(firebaseAuthService: firebaseAuthService, userDefaultsManager: userDefaultsManager)
    }
    
    // MARK: - Internal Methods
    @MainActor
    func createPriceAlert(targetPrice: Double?) async {
        guard let userID, let deviceToken, let targetPrice else {
            print("User ID, or device token, or target price is nil")
            return
        }
        
        isCreatingPriceAlert = true
        defer { isCreatingPriceAlert = false }
        
        do {
            let priceAlert = PriceAlert(
                id: coin.id + "_" + UUID().uuidString,
                symbol: coin.symbol,
                targetPrice: targetPrice,
                targetDirection: (coin.currentPrice ?? .zero) < targetPrice ? .above : .below
            )
            let createdPriceAlert = try await priceAlertService.createPriceAlert(priceAlert, userID: userID, deviceToken: deviceToken)
            coin.priceAlerts.append(createdPriceAlert)
        } catch {
            setErrorMessage(error)
        }
    }
    
    @MainActor
    func deletePriceAlert(_ priceAlert: PriceAlert) async {
        guard let userID, let deviceToken else {
            print("User ID or device token is nil")
            return
        }
        
        deletingPriceAlertIDs.append(priceAlert.id)
        defer {
            if let index  = deletingPriceAlertIDs.firstIndex(of: priceAlert.id) {
                deletingPriceAlertIDs.remove(at: index)
            }
        }
        
        do {
            let deletedPriceAlert = try await priceAlertService.deletePriceAlert(priceAlert, userID: userID, deviceToken: deviceToken)
            if let index = coin.priceAlerts.firstIndex(where: { $0.id == deletedPriceAlert.id }) {
                coin.priceAlerts.remove(at: index)
            }
        } catch {
            setErrorMessage(error)
        }
    }
    
    func shouldDisableCreateButton(targetPrice: Double?) -> Bool {
        targetPrice == nil ||
        targetPrice == .zero ||
        coin.priceAlerts.map(\.targetPrice).contains(targetPrice)
    }
    
    func getTargetDirection(for targetPrice: Double) -> PriceAlert.TargetDirection {
        targetPrice >= (coin.currentPrice ?? .zero) ? .above : .below
    }
}
