//
//  PriceAlertService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

protocol PriceAlertService {
    func getPriceAlerts(authToken: String, deviceToken: String) async throws -> [PriceAlert]
    func createPriceAlert(_ priceAlert: PriceAlert, authToken: String, deviceToken: String) async throws -> PriceAlert
    func deletePriceAlert(_ priceAlert: PriceAlert, authToken: String, deviceToken: String) async throws -> PriceAlert
}

final class PriceAlertServiceImpl: BaseBackendService, PriceAlertService {
    // MARK: - PriceAlertService
    func getPriceAlerts(authToken: String, deviceToken: String) async throws -> [PriceAlert] {
        do {
            let data = try await httpClient.get(
                path: "price-alerts",
                headers: [
                    "Authorization": "Bearer \(authToken)",
                    "X-Device-ID": deviceToken
                ]
            )
            let priceAlerts = try decoder.decode([PriceAlert].self, from: data)
            return priceAlerts
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func createPriceAlert(_ priceAlert: PriceAlert, authToken: String, deviceToken: String) async throws -> PriceAlert {
        do {
            let body = try encoder.encode(priceAlert)
            let data = try await httpClient.post(
                path: "price-alerts",
                headers: [
                    "Authorization": "Bearer \(authToken)",
                    "X-Device-ID": deviceToken
                ],
                body: body
            )
            let priceAlert = try decoder.decode(PriceAlert.self, from: data)
            return priceAlert
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func deletePriceAlert(_ priceAlert: PriceAlert, authToken: String, deviceToken: String) async throws -> PriceAlert {
        do {
            let data = try await httpClient.delete(
                path: "price-alerts/\(priceAlert.id)",
                headers: [
                    "Authorization": "Bearer \(authToken)",
                    "X-Device-ID": deviceToken
                ]
            )
            let priceAlert = try decoder.decode(PriceAlert.self, from: data)
            return priceAlert
        } catch {
            throw mapToAPIError(error)
        }
    }
}
