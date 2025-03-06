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
    func updatePriceAlert(_ id: String, isActive: Bool, authToken: String) async throws -> PriceAlert
    func deletePriceAlert(_ id: String, authToken: String) async throws -> PriceAlert
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
    
    func updatePriceAlert(_ id: String, isActive: Bool, authToken: String) async throws -> PriceAlert {
        do {
            let request = PriceAlertStateRequest(isActive: isActive)
            let body = try encoder.encode(request)
            let data = try await httpClient.put(
                path: "price-alerts/\(id)/state",
                headers: ["Authorization": "Bearer \(authToken)"],
                body: body
            )
            let priceAlert = try decoder.decode(PriceAlert.self, from: data)
            return priceAlert
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func deletePriceAlert(_ id: String, authToken: String) async throws -> PriceAlert {
        do {
            let data = try await httpClient.delete(
                path: "price-alerts/\(id)",
                headers: ["Authorization": "Bearer \(authToken)"]
            )
            let priceAlert = try decoder.decode(PriceAlert.self, from: data)
            return priceAlert
        } catch {
            throw mapToAPIError(error)
        }
    }
}
