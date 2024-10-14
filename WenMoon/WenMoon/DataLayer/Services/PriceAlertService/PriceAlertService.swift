//
//  PriceAlertService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

protocol PriceAlertService {
    func getPriceAlerts(deviceToken: String) async throws -> [PriceAlert]
    func setPriceAlert(for coin: CoinData, deviceToken: String) async throws -> PriceAlert
    func deletePriceAlert(for id: String, deviceToken: String) async throws -> PriceAlert
}

final class PriceAlertServiceImpl: BaseBackendService, PriceAlertService {

    // MARK: - PriceAlertService

    func getPriceAlerts(deviceToken: String) async throws -> [PriceAlert] {
        let data = try await httpClient.get(path: "price-alerts", headers: ["X-Device-ID": deviceToken])
        do {
            let priceAlerts = try decoder.decode([PriceAlert].self, from: data)
            print("Price Alerts: \(priceAlerts)")
            return priceAlerts
        } catch {
            throw mapToAPIError(error)
        }
    }

    func setPriceAlert(for coin: CoinData, deviceToken: String) async throws -> PriceAlert {
        do {
            let targetPrice = coin.targetPrice ?? .zero
            let request = PriceAlert(coinId: coin.id,
                                     coinName: coin.name,
                                     targetPrice: targetPrice,
                                     targetDirection: coin.currentPrice < targetPrice ? .above : .below)
            let body = try encoder.encode(request)
            let data = try await httpClient.post(path: "price-alert", headers: ["X-Device-ID": deviceToken], body: body)
            return try decoder.decode(PriceAlert.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }

    func deletePriceAlert(for id: String, deviceToken: String) async throws -> PriceAlert {
        let data = try await httpClient.delete(path: "price-alert/\(id)", headers: ["X-Device-ID": deviceToken])
        do {
            return try decoder.decode(PriceAlert.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
}
