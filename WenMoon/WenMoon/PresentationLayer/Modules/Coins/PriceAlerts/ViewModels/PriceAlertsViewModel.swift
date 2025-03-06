//
//  PriceAlertsViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 28.11.24.
//

import Foundation

final class PriceAlertsViewModel: BaseViewModel {
    // MARK: - Properties
    private let priceAlertService: PriceAlertService
    private let firebaseAuthService: FirebaseAuthService
    
    @Published private(set) var isCreatingPriceAlert = false
    
    // MARK: - Initializers
    convenience init() {
        self.init(
            priceAlertService: PriceAlertServiceImpl(),
            firebaseAuthService: FirebaseAuthServiceImpl()
        )
    }
    
    init(
        priceAlertService: PriceAlertService,
        firebaseAuthService: FirebaseAuthService,
        userDefaultsManager: UserDefaultsManager? = nil
    ) {
        self.priceAlertService = priceAlertService
        self.firebaseAuthService = firebaseAuthService
        super.init(userDefaultsManager: userDefaultsManager)
    }
    
    // MARK: - Internal Methods
    @MainActor
    func fetchPriceAlerts() async -> [PriceAlert] {
        guard let deviceToken else {
            setErrorMessage("Device token is missing")
            return []
        }
        
        do {
            let authToken = try await firebaseAuthService.getIDToken()
            let priceAlerts = try await priceAlertService.getPriceAlerts(authToken: authToken, deviceToken: deviceToken)
            return priceAlerts
        } catch {
            setError(error)
            return []
        }
    }
    
    @MainActor
    func createPriceAlert(for coin: CoinData, targetPrice: Double) async {
        guard let deviceToken else {
            setErrorMessage("Device token is missing")
            return
        }
        
        isCreatingPriceAlert = true
        defer { isCreatingPriceAlert = false }
        
        do {
            let priceAlert = PriceAlert(
                id: UUID().uuidString,
                coinID: coin.id,
                symbol: coin.symbol,
                targetPrice: targetPrice,
                targetDirection: (coin.currentPrice ?? .zero) < targetPrice ? .above : .below,
                isActive: true
            )
            
            let authToken = try await firebaseAuthService.getIDToken()
            let createdPriceAlert = try await priceAlertService.createPriceAlert(
                priceAlert,
                authToken: authToken,
                deviceToken: deviceToken
            )
            
            coin.priceAlerts.append(createdPriceAlert)
            save()
        } catch {
            setError(error)
        }
        
        triggerImpactFeedback()
    }
    
    @MainActor
    func updatePriceAlert(_ id: String, isActive: Bool, for coin: CoinData) async {
        do {
            let authToken = try await firebaseAuthService.getIDToken()
            let updatedPriceAlert = try await priceAlertService.updatePriceAlert(
                id,
                isActive: isActive,
                authToken: authToken
            )
            
            if let index = coin.priceAlerts.firstIndex(where: { $0.id == updatedPriceAlert.id }) {
                coin.priceAlerts[index].isActive = updatedPriceAlert.isActive
            }
            
            save()
        } catch {
            setError(error)
        }
    }
    
    @MainActor
    func deletePriceAlert(_ id: String, for coin: CoinData) async {
        do {
            let authToken = try await firebaseAuthService.getIDToken()
            let deletedPriceAlert = try await priceAlertService.deletePriceAlert(id, authToken: authToken)
            
            if let index = coin.priceAlerts.firstIndex(where: { $0.id == deletedPriceAlert.id }) {
                coin.priceAlerts.remove(at: index)
            }
            
            save()
        } catch {
            setError(error)
        }
    }
    
    func shouldDisableCreateButton(priceAlerts: [PriceAlert], targetPrice: Double?) -> Bool {
        targetPrice == nil ||
        targetPrice == .zero ||
        priceAlerts.map(\.targetPrice).contains(targetPrice)
    }
    
    func getTargetDirection(for targetPrice: Double, price: Double?) -> PriceAlert.TargetDirection {
        targetPrice >= (price ?? .zero) ? .above : .below
    }
}
